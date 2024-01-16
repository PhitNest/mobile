import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:json_types/json.dart';

base class User extends Json {
  final idJson = Json.string('id');
  final firstNameJson = Json.string('firstName');
  final lastNameJson = Json.string('lastName');
  final identityIdJson = Json.string('identityId');

  String get id => idJson.value;
  String get firstName => firstNameJson.value;
  String get lastName => lastNameJson.value;
  String get identityId => identityIdJson.value;

  String get fullName => '$firstName $lastName';

  User.parse(super.json) : super.parse();

  User.parser() : super();

  User.populated({
    required String id,
    required String firstName,
    required String lastName,
    required String identityId,
  }) : super() {
    idJson.populate(id);
    firstNameJson.populate(firstName);
    lastNameJson.populate(lastName);
    identityIdJson.populate(identityId);
  }

  @override
  List<JsonKey<dynamic, dynamic>> get keys =>
      [idJson, firstNameJson, lastNameJson, identityIdJson];
}

final class UserWithEmail extends User {
  final emailJson = Json.string('email');

  String get email => emailJson.value;

  UserWithEmail.parse(super.json) : super.parse();

  UserWithEmail.parser() : super.parser();

  UserWithEmail.populated({
    required String email,
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.identityId,
  }) : super.populated() {
    emailJson.populate(email);
  }

  @override
  List<JsonKey<dynamic, dynamic>> get keys => [...super.keys, emailJson];
}

final class ExploreUser extends Equatable {
  final Image profilePicture;
  final User user;

  const ExploreUser({
    required this.user,
    required this.profilePicture,
  }) : super();

  @override
  List<Object?> get props => [user, profilePicture];
}
