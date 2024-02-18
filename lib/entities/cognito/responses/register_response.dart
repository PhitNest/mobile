import 'package:equatable/equatable.dart';

import '../../entities.dart';

sealed class RegisterResponse extends Equatable {
  const RegisterResponse();
}

final class RegisterSuccess extends RegisterResponse {
  final UnauthenticatedSession session;
  final String password;

  const RegisterSuccess(
    this.session,
    this.password,
  ) : super();

  @override
  List<Object?> get props => [session, password];
}

sealed class RegisterFailureResponse extends RegisterResponse {
  String get message;

  const RegisterFailureResponse() : super();
}

enum RegisterFailureType {
  userExists,
  invalidUserPool;

  String get message => switch (this) {
        RegisterFailureType.userExists =>
          'A user with that email already exists.',
        RegisterFailureType.invalidUserPool => 'Please update your app.',
      };
}

final class RegisterKnownFailure extends RegisterFailureResponse {
  @override
  String get message => type.message;

  final RegisterFailureType type;

  const RegisterKnownFailure(this.type) : super();

  @override
  List<Object?> get props => [type];
}

final class ValidationFailure extends RegisterFailureResponse {
  @override
  final String message;

  const ValidationFailure(this.message) : super();

  @override
  List<Object?> get props => [message];
}

final class RegisterUnknownFailure extends RegisterFailureResponse {
  @override
  final String message;

  const RegisterUnknownFailure({
    required String? message,
  })  : message = message ?? 'An unknown error occurred.',
        super();

  @override
  List<Object?> get props => [message];
}
