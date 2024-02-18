import '../util/to_json.dart';

final class LogEvent with ToJson {
  final String action;
  final String details;
  final String? userId;

  const LogEvent({
    required this.action,
    required this.details,
    this.userId,
  });

  @override
  Map<String, dynamic> toJson() => {
        'action': action,
        'details': details,
        if (userId != null) 'userId': userId,
      };
}
