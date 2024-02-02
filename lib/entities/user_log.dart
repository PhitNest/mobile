import 'package:json_types/json.dart';

final class LogEvent extends Json {
  final action = Json.string('action');
  final details = Json.string('details');

  LogEvent.populed({
    required String action,
    required String details,
  }) : super() {
    this.action.populate(action);
    this.details.populate(details);
  }

  LogEvent.parse(super.json) : super.parse();

  LogEvent.parser() : super();

  @override
  List<JsonKey<dynamic, dynamic>> get keys => [action, details];
}
