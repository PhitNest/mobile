import 'package:equatable/equatable.dart';
import 'package:parse_json/parse_json.dart';

base class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? identityId;

  static final properties = <String, JsonProperty<dynamic>>{
    'id': string,
    'firstName': string,
    'lastName': string,
    'identityId': string.optional,
  };

  String get fullName => '$firstName $lastName';

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.identityId,
  }) : super();

  factory User.fromJson(dynamic json) => parse(User.new, json, properties);

  @override
  List<Object?> get props => [id, firstName, lastName, identityId];
}

final class UserWithEmail extends User {
  final String email;

  static final properties = {
    ...User.properties,
    'email': string,
  };

  const UserWithEmail({
    required super.id,
    required super.firstName,
    required super.lastName,
    required this.email,
    super.identityId,
  }) : super();

  factory UserWithEmail.fromJson(dynamic json) =>
      parse(UserWithEmail.new, json, properties);

  @override
  List<Object?> get props => [...super.props, email];
}
