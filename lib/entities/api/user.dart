import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:parse_json/parse_json.dart';

base class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String identityId;

  static const properties = {
    'id': string,
    'firstName': string,
    'lastName': string,
    'identityId': string,
  };

  String get fullName => '$firstName $lastName';

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.identityId,
  }) : super();

  factory User.fromJson(dynamic json) => parse(User.new, json, properties);

  @override
  List<Object> get props => [id, firstName, lastName, identityId];
}

final class UserWithEmail extends User {
  final String email;

  static const properties = {
    ...User.properties,
    'email': string,
  };

  const UserWithEmail({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.identityId,
    required this.email,
  }) : super();

  factory UserWithEmail.fromJson(dynamic json) =>
      parse(UserWithEmail.new, json, properties);

  @override
  List<Object> get props => [...super.props, email];
}

final class ExploreUser extends User {
  final Image profilePicture;

  const ExploreUser({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.identityId,
    required this.profilePicture,
  }) : super();

  @override
  List<Object> get props => [...super.props, profilePicture];
}
