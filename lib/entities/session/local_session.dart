import 'dart:convert';

import 'package:json_types/json.dart';

import 'session.dart';

final class LocalUnauthenticatedSession extends UnauthenticatedSession {
  final String userId;
  final String identityId;

  const LocalUnauthenticatedSession(this.userId, this.identityId) : super();

  @override
  List<Object?> get props => [userId, identityId];
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

sealed class LocalSessionDataJson
    extends JsonPolymorphic<LocalSessionDataJson> {
  final userIdJson = Json.string('userId');
  final identityIdJson = Json.string('identityId');

  String get userId => userIdJson.value;
  String get identityId => identityIdJson.value;

  LocalSessionDataJson.populated({
    required String userId,
    required String identityId,
  }) : super() {
    userIdJson.populate(userId);
    identityIdJson.populate(identityId);
  }

  LocalSessionDataJson.parse(super.json) : super.parse();

  LocalSessionDataJson.parser() : super();

  static const List<LocalSessionDataJson Function()> parsers = [
    LocalSessionJson.parser,
    LocalUnauthenticatedSessionJson.parser
  ];

  @override
  List<JsonKey<dynamic, dynamic>> get keys => [userIdJson, identityIdJson];
}

final class LocalSessionJson extends LocalSessionDataJson {
  LocalSessionJson.parse(super.json) : super.parse();

  late final LocalSession session = LocalSession(
    userIdJson.value,
    identityIdJson.value,
  );

  LocalSessionJson.populated({
    required super.userId,
    required super.identityId,
  }) : super.populated();

  LocalSessionJson.parser() : super.parser();

  @override
  String get type => 'LocalSession';
}

final class LocalUnauthenticatedSessionJson extends LocalSessionDataJson {
  LocalUnauthenticatedSessionJson.parse(super.json) : super.parse();

  late final LocalUnauthenticatedSession session = LocalUnauthenticatedSession(
    userIdJson.value,
    identityIdJson.value,
  );

  LocalUnauthenticatedSessionJson.populated({
    required super.userId,
    required super.identityId,
  }) : super.populated();

  LocalUnauthenticatedSessionJson.parser() : super.parser();

  @override
  String get type => 'LocalUnauthenticatedSession';
}
