import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../config/aws.dart';
import '../../entities/session/session.dart';
import '../bloc/bloc.dart';
import '../failure.dart';
import '../logger.dart';

part 'response.dart';

/// Default HTTP timeout
const kDefaultTimeout = Duration(seconds: 30);

/// Enum for supported HTTP methods
enum HttpMethod {
  get,
  post,
  put,
  delete,
}

/// Helper method to create the URL for the request
String createUrl(
  String host,
  String port,
  String route,
) {
  final portString =
      port.isEmpty || port == '443' || port == '80' ? '' : ':$port';
  return '$host$portString$route';
}

String _host = kHost;
String _port = kPort;
Duration _timeout = kDefaultTimeout;

/// Initialize the Http instance with custom settings
void initializeHttp({String? host, String? port, Duration? timeout}) {
  _host = host ?? _host;
  _port = port ?? _port;
  _timeout = timeout ?? _timeout;
}

Future<HttpResponse<ResType>> request<ResType>({
  required String route,
  required HttpMethod method,
  required ResType Function(dynamic) parse,
  Map<String, dynamic>? data,
  Map<String, dynamic>? headers,
  Session? session,
  String? overrideHost,
  String? overridePort,
}) async {
  // Record the start time of the request for logging purposes
  final startTime = DateTime.now();

  // Create the URL for the request
  final url = createUrl(overrideHost ?? _host, overridePort ?? _port, route);

  // Helper function for generating log descriptions
  List<String> details(dynamic data) =>
      ['method: $method', 'url: $url', 'data: $data'];

  // Log the request details
  debug('Request${session != null ? " (Authorized)" : ""}:',
      details: details(data));

  int elapsedMs() =>
      DateTime.now().millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;

  List<String> responseDetails(dynamic data) =>
      [...details(data), 'elapsed: ${elapsedMs()} ms'];

  // Prepare the request headers
  final headerMap = {
    ...headers ?? Map<String, dynamic>.from({}),
    ...session != null
        ? {'Authorization': session.idToken}
        : Map<String, dynamic>.from({}),
  };

  // Create Dio instance with the prepared headers and options
  final options =
      BaseOptions(headers: headerMap, validateStatus: (status) => true);
  if (data != null &&
      (method == HttpMethod.get || method == HttpMethod.delete)) {
    options.queryParameters = data;
  }
  final dio = Dio(options);

  // Perform the request and handle the response
  try {
    return await switch (method) {
      HttpMethod.get => dio.get<dynamic>(url),
      HttpMethod.post => dio.post<dynamic>(url, data: data),
      HttpMethod.put => dio.put<dynamic>(url, data: data),
      HttpMethod.delete => dio.delete<dynamic>(url),
    }
        .timeout(_timeout)
        .then((response) async {
      final jsonData = response.data;
      if (jsonData is Map<String, dynamic> || jsonData is List<dynamic>) {
        // Handle successful responses
        if (response.statusCode == 200) {
          // Parse the response data
          final parsed = parse(jsonData);
          // Log success
          debug(
            'Request success:',
            details: responseDetails(parsed),
          );
          return HttpResponseSuccess(parsed, response.headers);
        } else {
          // Handle unsuccessful responses
          error('Request failure:',
              details: responseDetails([jsonData.toString()]));
          final parsed = Failure.fromJson(jsonData as Map<String, dynamic>);
          return HttpResponseFailure(parsed, response.headers);
        }
      } else {
        throw Failure(type: 'Invalid response', message: jsonData.toString());
      }
    });
  } on TimeoutException {
    error('Request timeout:', details: responseDetails(data));
    return HttpResponseFailure(
        const Failure(type: 'Timeout', message: 'Request timeout'), Headers());
  } on Failure catch (failure) {
    error('Request failure:', details: responseDetails(failure));
    return HttpResponseFailure(failure, Headers());
  } catch (e) {
    // Log and return an unknown failure
    final failure = Failure(type: 'UnknownFailure', message: e.toString());
    await logError('Request failure:',
        details: responseDetails(failure), userId: session?.userId);
    return HttpResponseFailure(failure, Headers());
  }
}
