import '../entities/user_log.dart';
import '../util/http/http.dart';

Future<HttpResponse<void>> postLogEvent(
  LogEvent logEvent,
) =>
    request(
      route: 'log',
      method: HttpMethod.post,
      data: logEvent.toJson(),
      parse: (_) {},
    );
