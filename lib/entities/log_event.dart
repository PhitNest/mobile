import 'package:json_types/json.dart';

final class LogEvent extends Json {
  final actionJson = Json.string('action');
  final detailsJson = Json.string('details');
  final userIdJson = Json.optionalString('userId');

  String get action => actionJson.value;
  String get details => detailsJson.value;
  String? get userId => userIdJson.value;

  LogEvent.populed({
    required String action,
    required String details,
    String? userId,
  }) : super() {
    actionJson.populate(action);
    detailsJson.populate(details);
    userIdJson.populate(userId);
  }

  LogEvent.parse(super.json) : super.parse();

  LogEvent.parser() : super();

  @override
  List<JsonKey<dynamic, dynamic>> get keys =>
      [actionJson, detailsJson, userIdJson];
}
