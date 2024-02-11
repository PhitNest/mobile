import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:equatable/equatable.dart';

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

final class LocalUnauthenticatedSession extends UnauthenticatedSession {
  final String userId;
  final String identityId;

  const LocalUnauthenticatedSession(this.userId, this.identityId) : super();

  @override
  List<Object?> get props => [userId, identityId];
}

final class AwsUnauthenticatedSession extends UnauthenticatedSession {
  final CognitoUser user;

  const AwsUnauthenticatedSession({
    required this.user,
  }) : super();

  @override
  List<Object?> get props => [user];
}

final class LocalSession extends Session {
  @override
  final String userId;

  final String identityId;

  late final String token = jsonEncode({'sub': userId, 'email': userId});

  @override
  bool get valid => true;

  @override
  String? get idToken => token;

  @override
  String get accessToken => token;

  LocalSession(this.userId, this.identityId) : super();

  @override
  List<Object?> get props => [userId, identityId];
}

final class AwsSession extends Session {
  final CognitoUser user;
  final CognitoCredentials credentials;
  final CognitoUserSession cognitoSession;

  @override
  String? get userId => user.username;

  @override
  bool get valid => cognitoSession.isValid();

  @override
  String? get idToken => cognitoSession.idToken.jwtToken;

  @override
  String? get accessToken => cognitoSession.accessToken.jwtToken;

  const AwsSession({
    required this.user,
    required this.cognitoSession,
    required this.credentials,
  }) : super();

  @override
  List<Object?> get props => [user, cognitoSession, credentials];
}
