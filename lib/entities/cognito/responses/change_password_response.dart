import 'package:equatable/equatable.dart';

import '../../session/session.dart';
import 'constants.dart';

sealed class ChangePasswordResponse extends Equatable {
  const ChangePasswordResponse() : super();
}

final class ChangePasswordSuccess extends ChangePasswordResponse {
  final Session session;

  const ChangePasswordSuccess(this.session) : super();

  @override
  List<Object?> get props => [session];
}

sealed class ChangePasswordFailureResponse extends ChangePasswordResponse {
  String get message;

  const ChangePasswordFailureResponse() : super();
}

enum ChangePasswordFailureType {
  invalidUserPool,
  invalidPassword,
  noSuchUser;

  String get message => switch (this) {
        ChangePasswordFailureType.invalidUserPool => kInvalidUserPool,
        ChangePasswordFailureType.invalidPassword => kInvalidPassword,
        ChangePasswordFailureType.noSuchUser => kNoSuchUser,
      };
}

final class ChangePasswordKnownFailure extends ChangePasswordFailureResponse {
  final ChangePasswordFailureType type;

  @override
  String get message => type.message;

  const ChangePasswordKnownFailure(this.type) : super();

  @override
  List<Object?> get props => [type];
}

final class ChangePasswordUnknownFailure extends ChangePasswordFailureResponse {
  @override
  final String message;

  const ChangePasswordUnknownFailure({
    required String? message,
  })  : message = message ?? kUnknownError,
        super();

  @override
  List<Object?> get props => [message];
}
