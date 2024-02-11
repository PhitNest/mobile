import '../../entities/entities.dart';

import 'cognito.dart';

final class LocalCognito extends Cognito {
  const LocalCognito() : super();

  @override
  Future<ChangePasswordResponse> changePassword({
    required String newPassword,
    required covariant LocalUnauthenticatedSession unauthenticatedSession,
  }) async =>
      ChangePasswordSuccess(LocalSession(
          unauthenticatedSession.userId, unauthenticatedSession.identityId));

  @override
  Future<String?> confirmEmail({
    required covariant LocalUnauthenticatedSession session,
    required String code,
  }) async =>
      null;

  @override
  Future<bool> deleteAccount(covariant LocalSession session) async => true;

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
  Future<void> logout(covariant LocalSession session) {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<RefreshSessionResponse> refreshSession(
      covariant LocalSession session) {
    // TODO: implement refreshSession
    throw UnimplementedError();
  }

  @override
  Future<RegisterResponse> register(RegisterParams params) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<String?> resendConfirmationEmail(
      covariant LocalUnauthenticatedSession session) {
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
    required covariant LocalUnauthenticatedSession session,
  }) {
    // TODO: implement submitForgotPassword
    throw UnimplementedError();
  }
}
