import 'package:equatable/equatable.dart';

import 'entities.dart';

sealed class SendForgotPasswordResponse extends Equatable {
  const SendForgotPasswordResponse() : super();
}

final class SendForgotPasswordSuccess extends SendForgotPasswordResponse {
  final UnauthenticatedSession session;

  const SendForgotPasswordSuccess(this.session) : super();

  @override
  List<Object?> get props => [session];
}

enum SendForgotPasswordFailure {
  invalidUserPool,
  invalidEmail,
  noSuchUser;

  String get message => switch (this) {
        SendForgotPasswordFailure.invalidUserPool => 'Please update your app.',
        SendForgotPasswordFailure.invalidEmail => 'Invalid email',
        SendForgotPasswordFailure.noSuchUser => 'No such user',
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

  final SendForgotPasswordFailure type;

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
  })  : message = message ?? 'An unknown error occurred.',
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
        SubmitForgotPasswordFailure.invalidUserPool =>
          ' Please update your app.',
        SubmitForgotPasswordFailure.invalidEmail => 'Invalid email.',
        SubmitForgotPasswordFailure.invalidPassword => 'Invalid password.',
        SubmitForgotPasswordFailure.noSuchUser => 'No such user.',
        SubmitForgotPasswordFailure.unknown => 'An unknown error occurred.',
        SubmitForgotPasswordFailure.invalidCodeOrPassword =>
          'Invalid code or password.',
        SubmitForgotPasswordFailure.invalidCode => 'Invalid code.',
        SubmitForgotPasswordFailure.expiredCode => 'Expired code.',
      };
}
