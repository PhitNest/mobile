import 'package:equatable/equatable.dart';
import '../../session/session.dart';
import 'constants.dart';

sealed class SendForgotPasswordResponse extends Equatable {
  const SendForgotPasswordResponse() : super();
}

final class SendForgotPasswordSuccess extends SendForgotPasswordResponse {
  final UnauthenticatedSession session;

  const SendForgotPasswordSuccess(this.session) : super();

  @override
  List<Object?> get props => [session];
}

enum SendForgotPasswordFailureType {
  invalidUserPool,
  invalidEmail,
  noSuchUser;

  String get message => switch (this) {
        SendForgotPasswordFailureType.invalidUserPool => kInvalidUserPool,
        SendForgotPasswordFailureType.invalidEmail => kInvalidEmail,
        SendForgotPasswordFailureType.noSuchUser => kNoSuchUser,
      };
}

sealed class SendForgotPasswordFailureResponse
    extends SendForgotPasswordResponse {
  String get message;

  const SendForgotPasswordFailureResponse() : super();
}

final class SendForgotPasswordKnownFailure
    extends SendForgotPasswordFailureResponse {
  @override
  String get message => type.message;

  final SendForgotPasswordFailureType type;

  const SendForgotPasswordKnownFailure(this.type) : super();

  @override
  List<Object?> get props => [type];
}

final class SendForgotPasswordUnknownFailure
    extends SendForgotPasswordFailureResponse {
  @override
  final String message;

  const SendForgotPasswordUnknownFailure({
    required String? message,
  })  : message = message ?? kUnknownError,
        super();

  @override
  List<Object?> get props => [message];
}

enum SubmitForgotPasswordFailure {
  invalidUserPool,
  invalidEmail,
  invalidPassword,
  noSuchUser,
  invalidCodeOrPassword,
  invalidCode,
  expiredCode,
  unknown;

  String get message => switch (this) {
        SubmitForgotPasswordFailure.invalidUserPool => kInvalidUserPool,
        SubmitForgotPasswordFailure.invalidEmail => kInvalidEmail,
        SubmitForgotPasswordFailure.invalidPassword => kInvalidPassword,
        SubmitForgotPasswordFailure.noSuchUser => kNoSuchUser,
        SubmitForgotPasswordFailure.unknown => kUnknownError,
        SubmitForgotPasswordFailure.invalidCodeOrPassword =>
          'Invalid code or password.',
        SubmitForgotPasswordFailure.invalidCode => 'Invalid code.',
        SubmitForgotPasswordFailure.expiredCode => 'Expired code.',
      };
}
