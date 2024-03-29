import 'package:equatable/equatable.dart';

import '../../session/session.dart';
import 'constants.dart';

sealed class LoginResponse extends Equatable {
  const LoginResponse() : super();
}

final class LoginSuccess<S extends Session> extends LoginResponse {
  final S session;

  const LoginSuccess({
    required this.session,
  }) : super();

  @override
  List<Object?> get props => [session];
}

enum LoginFailureType {
  invalidEmailPassword,
  noSuchUser,
  invalidUserPool;

  String get message => switch (this) {
        LoginFailureType.invalidEmailPassword => 'Invalid email/password.',
        LoginFailureType.noSuchUser => kNoSuchUser,
        LoginFailureType.invalidUserPool => kInvalidUserPool,
      };
}

sealed class LoginFailureResponse extends LoginResponse {
  String get message;

  const LoginFailureResponse() : super();
}

final class LoginKnownFailure extends LoginFailureResponse {
  final LoginFailureType type;

  @override
  String get message => type.message;

  const LoginKnownFailure(this.type) : super();

  @override
  List<Object?> get props => [type];
}

final class LoginConfirmationRequired<U extends UnauthenticatedSession>
    extends LoginFailureResponse {
  @override
  String get message => 'Confirmation required.';

  final UnauthenticatedSession session;
  final String password;

  const LoginConfirmationRequired({
    required this.session,
    required this.password,
  }) : super();

  @override
  List<Object?> get props => [session, password];
}

final class LoginUnknownResponse extends LoginFailureResponse {
  @override
  final String message;

  const LoginUnknownResponse({
    required String? message,
  })  : message = message ?? kUnknownError,
        super();

  @override
  List<Object?> get props => [message];
}

final class LoginChangePasswordRequired extends LoginFailureResponse {
  final UnauthenticatedSession session;

  @override
  String get message => 'Change password required.';

  const LoginChangePasswordRequired(this.session) : super();

  @override
  List<Object?> get props => [session];
}
