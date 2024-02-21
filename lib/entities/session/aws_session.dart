import 'package:amazon_cognito_identity_dart_2/cognito.dart';

import 'session.dart';

final class AwsUnauthenticatedSession extends UnauthenticatedSession {
  final CognitoUser user;

  const AwsUnauthenticatedSession({
    required this.user,
  }) : super();

  @override
  List<Object?> get props => [user];
}

final class AwsSession extends Session {
  final CognitoUser user;
  final CognitoCredentials credentials;
  final CognitoUserSession cognitoSession;

  @override
  String get userId => user.username!;

  @override
  bool get valid => cognitoSession.isValid();

  @override
  String get idToken => cognitoSession.idToken.jwtToken!;

  @override
  String get accessToken => cognitoSession.accessToken.jwtToken!;

  const AwsSession({
    required this.user,
    required this.cognitoSession,
    required this.credentials,
  }) : super();

  @override
  List<Object?> get props => [user, cognitoSession, credentials];
}
