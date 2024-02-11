import '../../config/use_local.dart';
import '../../entities/entities.dart';
import 'aws.dart';
import 'local.dart';

abstract base class Cognito {
  static Cognito get instance =>
      kLocal ? const LocalCognito() : const AwsCognito();

  const Cognito() : super();

  Future<ChangePasswordResponse> changePassword({
    required String newPassword,
    required UnauthenticatedSession unauthenticatedSession,
  });

  /// Verifies a users email address using a 6-digit pin code sent by AWS
  /// Cognito
  ///
  /// Returns null if successful, otherwise an error message
  Future<String?> confirmEmail({
    required UnauthenticatedSession session,
    required String code,
  });

  Future<String?> resendConfirmationEmail(UnauthenticatedSession session);

  Future<void> logout(Session session);

  Future<bool> deleteAccount(Session session);

  Future<RegisterResponse> register(RegisterParams params);

  Future<RefreshSessionResponse> refreshSession(Session session);

  Future<RefreshSessionResponse> getPreviousSession();

  Future<LoginResponse> login(LoginParams params);

  Future<SendForgotPasswordResponse> sendForgotPasswordRequest(String email);

  Future<SubmitForgotPasswordFailure?> submitForgotPassword({
    required SubmitForgotPasswordParams params,
    required UnauthenticatedSession session,
  });
}
