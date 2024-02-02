import 'package:basic_utils/basic_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart' hide LogEvent;

import '../entities/log_event.dart';
import '../repositories/log_event.dart';

const kDetailLinePrefix = '\n\t';

final _prettyLogger = Logger(printer: PrettyPrinter(methodCount: 0));

Future<void> logError(String title,
    {List<String>? details, String? userId}) async {
  final (_, title: action, details: d) = _logMessage(title, details);
  await postLogEvent(
      LogEvent.populed(action: action, details: d, userId: userId));
}

String _wrapText(String text, int spaces) => StringUtils.addCharAtPosition(
      text,
      '\n${List.filled(spaces, '\t').join()}',
      100,
      repeat: true,
    );

(String, {String title, String details}) _logMessage(
    String title, List<String>? details) {
  final detailString = details != null
      ? '$kDetailLinePrefix${details.map((e) => _wrapText(e, 2)).join(
            kDetailLinePrefix,
          )}'
      : '';
  final text = '${_wrapText(title, 0)}$detailString';
  return (text, title: title, details: detailString);
}

void debug(String title, {List<String>? details}) =>
    _prettyLogger.d(_logMessage(title, details).$1);

void info(String title, {List<String>? details}) =>
    _prettyLogger.i(_logMessage(title, details).$1);

void warning(String title, {List<String>? details}) =>
    _prettyLogger.w(_logMessage(title, details).$1);

void error(String title, {List<String>? details}) =>
    _prettyLogger.e(_logMessage(title, details).$1);

void badState(Equatable state, Equatable event) =>
    error('$state:\n\tInvalid event: $event');
