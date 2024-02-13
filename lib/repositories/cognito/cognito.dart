import '../../config/use_local.dart';
import '../../entities/entities.dart';
import 'aws.dart';
import 'local.dart';

abstract base class Cognito<U extends UnauthenticatedSession,
    S extends Session> {
  const Cognito() : super();

  Future<ChangePasswordResponse> changePassword({
    required String newPassword,
    required U unauthenticatedSession,
  });

  Future<String?> confirmEmail({
    required U session,
    required String code,
  });

  Future<String?> resendConfirmationEmail(U session);

  Future<void> logout(S session);

  Future<bool> deleteAccount(S session);

  Future<RegisterResponse> register(RegisterParams params);

  Future<RefreshSessionResponse> refreshSession(S session);

  Future<RefreshSessionResponse> getPreviousSession();

  Future<LoginResponse> login(LoginParams params);

  Future<SendForgotPasswordResponse> sendForgotPasswordRequest(String email);

  Future<SubmitForgotPasswordFailure?> submitForgotPassword({
    required SubmitForgotPasswordParams params,
    required U session,
  });
}

Cognito get _instance =>
    kLocal ? const LocalCognito() : const AwsCognito() as Cognito;

Future<ChangePasswordResponse> changePassword({
  required String newPassword,
  required UnauthenticatedSession unauthenticatedSession,
}) =>
    _instance.changePassword(
      newPassword: newPassword,
      unauthenticatedSession: unauthenticatedSession,
    );

/// Verifies a users email address using a 6-digit pin code sent by AWS
/// Cognito
///
/// Returns null if successful, otherwise an error message
Future<String?> confirmEmail({
  required UnauthenticatedSession session,
  required String code,
}) =>
    _instance.confirmEmail(session: session, code: code);

Future<String?> resendConfirmationEmail(UnauthenticatedSession session) =>
    _instance.resendConfirmationEmail(session);

Future<void> logout(Session session) => _instance.logout(session);

Future<bool> deleteAccount(Session session) => _instance.deleteAccount(session);

Future<RegisterResponse> register(RegisterParams params) =>
    _instance.register(params);

Future<RefreshSessionResponse> refreshSession(Session session) =>
    _instance.refreshSession(session);

Future<RefreshSessionResponse> getPreviousSession() =>
    _instance.getPreviousSession();

Future<LoginResponse> login(LoginParams params) => _instance.login(params);

Future<SendForgotPasswordResponse> sendForgotPasswordRequest(String email) =>
    _instance.sendForgotPasswordRequest(email);

Future<SubmitForgotPasswordFailure?> submitForgotPassword({
  required SubmitForgotPasswordParams params,
  required UnauthenticatedSession session,
}) =>
    _instance.submitForgotPassword(params: params, session: session);
