import 'package:basic_utils/basic_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart' hide LogEvent;

import '../entities/log_event.dart';
import '../repositories/log_event.dart';

const kDetailLinePrefix = '\n\t';

final _prettyLogger = Logger(printer: PrettyPrinter(methodCount: 0));

final _messages = <LogEvent>[];

Future<void> logToDb() async {
  if (_messages.isNotEmpty) {
    info('Logging to sentry...');
    await Future.wait(_messages.map((message) => postLogEvent(message)));
    _messages.clear();
  }
}

String _wrapText(String text, int spaces) => StringUtils.addCharAtPosition(
      text,
      '\n${List.filled(spaces, '\t').join()}',
      100,
      repeat: true,
    );

String _logMessage(String title, List<String>? details, {String userId = ''}) {
  final detailString = details != null
      ? '$kDetailLinePrefix${details.map((e) => _wrapText(e, 2)).join(
            kDetailLinePrefix,
          )}'
      : '';
  final text = '${_wrapText(title, 0)}$detailString';
  _messages.add(
      LogEvent.populed(action: title, details: detailString, userId: userId));
  return text;
}

void debug(String title, {List<String>? details}) =>
    _prettyLogger.d(_logMessage(title, details));

void info(String title, {List<String>? details}) =>
    _prettyLogger.i(_logMessage(title, details));

void warning(String title, {List<String>? details}) =>
    _prettyLogger.w(_logMessage(title, details));

void error(String title, {List<String>? details}) =>
    _prettyLogger.e(_logMessage(title, details));

void badState(Equatable state, Equatable event) =>
    error('$state:\n\tInvalid event: $event');
