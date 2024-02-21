import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:parse_json/parse_json.dart';

import '../../util/to_json.dart';
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
  String get idToken => token;

  @override
  String get accessToken => token;

  LocalSession(this.userId, this.identityId) : super();

  @override
  List<Object?> get props => [userId, identityId];
}

sealed class LocalSessionDataJson extends Equatable with ToJson {
  static const polymorphicKey = 'type';

  final String userId;
  final String identityId;

  static const properties = {
    'userId': string,
    'identityId': string,
  };

  const LocalSessionDataJson({
    required this.userId,
    required this.identityId,
  }) : super();

  factory LocalSessionDataJson.fromJson(dynamic json) =>
      polymorphicParse(polymorphicKey, json, {
        LocalSessionJson.polymorphicId: LocalSessionJson.fromJson,
        LocalUnauthenticatedSessionJson.polymorphicId:
            LocalUnauthenticatedSessionJson.fromJson,
      });

  @override
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'identityId': identityId,
      };

  @override
  List<Object?> get props => [userId, identityId];
}

final class LocalSessionJson extends LocalSessionDataJson {
  static const polymorphicId = 'LocalSession';

  LocalSession get session => LocalSession(userId, identityId);

  const LocalSessionJson({
    required super.userId,
    required super.identityId,
  }) : super();

  factory LocalSessionJson.fromJson(dynamic json) =>
      parse(LocalSessionJson.new, json, LocalSessionDataJson.properties);

  @override
  List<Object?> get props => [...super.props, session];
}

final class LocalUnauthenticatedSessionJson extends LocalSessionDataJson {
  static const polymorphicId = 'LocalUnauthenticatedSession';

  LocalUnauthenticatedSession get session =>
      LocalUnauthenticatedSession(userId, identityId);

  const LocalUnauthenticatedSessionJson({
    required super.userId,
    required super.identityId,
  }) : super();

  factory LocalUnauthenticatedSessionJson.fromJson(dynamic json) => parse(
        LocalUnauthenticatedSessionJson.new,
        json,
        LocalSessionDataJson.properties,
      );

  @override
  List<Object?> get props => [...super.props, session];
}
