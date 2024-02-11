import 'package:amazon_cognito_identity_dart_2/cognito.dart';

import '../../entities/entities.dart';

import 'cognito.dart';

final class LocalCognito extends Cognito {
  const LocalCognito() : super();

  @override
  Future<ChangePasswordResponse> changePassword({
    required String newPassword,
    required UnauthenticatedSession unauthenticatedSession,
  }) {
    // TODO: implement changePassword
    throw UnimplementedError();
  }

  @override
  Future<String?> confirmEmail({
    required CognitoUser user,
    required String code,
  }) {
    // TODO: implement confirmEmail
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteAccount(Session session) {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<RefreshSessionResponse> getPreviousSession() {
    // TODO: implement getPreviousSession
    throw UnimplementedError();
  }

  @override
  Future<LoginResponse> login(LoginParams params) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<void> logout(Session session) {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<RefreshSessionResponse> refreshSession(Session session) {
    // TODO: implement refreshSession
    throw UnimplementedError();
  }

  @override
  Future<RegisterResponse> register(RegisterParams params) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<String?> resendConfirmationEmail(CognitoUser user) {
    // TODO: implement resendConfirmationEmail
    throw UnimplementedError();
  }

  @override
  Future<SendForgotPasswordResponse> sendForgotPasswordRequest(String email) {
    // TODO: implement sendForgotPasswordRequest
    throw UnimplementedError();
  }

  @override
  Future<SubmitForgotPasswordFailure?> submitForgotPassword({
    required SubmitForgotPasswordParams params,
    required UnauthenticatedSession session,
  }) {
    // TODO: implement submitForgotPassword
    throw UnimplementedError();
  }
}
