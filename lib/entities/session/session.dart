import 'package:equatable/equatable.dart';

export 'aws_session.dart';
export 'local_session.dart';

abstract base class Session extends Equatable {
  String? get accessToken;
  String? get idToken;
  String? get userId;
  bool get valid;

  const Session();
}

abstract base class UnauthenticatedSession extends Equatable {
  const UnauthenticatedSession() : super();
}
