final class LogEvent {
  final String action;
  final String details;
  final String? userId;

  const LogEvent({
    required this.action,
    required this.details,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'action': action,
        'details': details,
        if (userId != null) 'userId': userId,
      };
}
