import '../../entities/entities.dart';

import '../../util/cache/cache.dart';
import 'cognito.dart';

extension on LocalSessionDataJson {
  Future<void> cache() => cacheObject('session:$userId', this);
}

Future<void> cacheLastUserId(String? userId) =>
    cacheString('lastUserId', userId);

String? get lastUserId => getCachedString('lastUserId');

LocalSessionDataJson? getLocalSessionJson(String userId) =>
    getCachedPolymorphic('session:$userId', LocalSessionDataJson.parsers);

final class LocalCognito
    extends Cognito<LocalUnauthenticatedSession, LocalSession> {
  const LocalCognito() : super();

  @override
  Future<ChangePasswordResponse> changePassword({
    required String newPassword,
    required LocalUnauthenticatedSession unauthenticatedSession,
  }) async {
    final localSessionJson = LocalSessionJson.populated(
      userId: unauthenticatedSession.userId,
      identityId: unauthenticatedSession.identityId,
    );
    await Future.wait([
      cacheLastUserId(unauthenticatedSession.userId),
      localSessionJson.cache()
    ]);
    return ChangePasswordSuccess(localSessionJson.session);
  }

  @override
  Future<String?> confirmEmail({
    required LocalUnauthenticatedSession session,
    required String code,
  }) async {
    final localSessionJson = LocalSessionJson.populated(
      userId: session.userId,
      identityId: session.identityId,
    );
    await Future.wait(
        [cacheLastUserId(session.userId), localSessionJson.cache()]);
    return null;
  }

  @override
  Future<bool> deleteAccount(LocalSession session) async {
    await Future.wait([
      cacheObject<LocalSessionDataJson>('session:${session.userId}', null),
      cacheLastUserId(null)
    ]);
    return true;
  }

  @override
  Future<RefreshSessionResponse> getPreviousSession() async {
    final userId = lastUserId;
    if (userId == null) {
      return const SessionEnded();
    }

    final localSessionJson = getLocalSessionJson(userId);
    if (localSessionJson == null) {
      return const SessionEnded();
    }

    switch (localSessionJson) {
      case LocalSessionJson():
        return RefreshSessionSuccess(localSessionJson.session);
      case LocalUnauthenticatedSessionJson():
        return const RefreshSessionKnownFailure(
          RefreshSessionFailureType.invalidToken,
        );
    }
  }

  @override
  Future<LoginResponse> login(LoginParams params) async {
    final localSessionJson = getLocalSessionJson(params.email);
    if (localSessionJson != null) {
      await cacheLastUserId(params.email);
      switch (localSessionJson) {
        case LocalSessionJson():
          return LoginSuccess(session: localSessionJson.session);
        case LocalUnauthenticatedSessionJson(session: final session):
          return LoginConfirmationRequired(session: session, password: '');
      }
    }

    return const LoginKnownFailure(LoginFailureType.noSuchUser);
  }

  @override
  Future<void> logout(LocalSession session) => cacheLastUserId(null);

  @override
  Future<RefreshSessionResponse> refreshSession(LocalSession session) async =>
      RefreshSessionSuccess(session);

  @override
  Future<RegisterResponse> register(RegisterParams params) async {
    final existingUser = getLocalSessionJson(params.email);

    if (existingUser == null) {
      final localSessionJson = LocalUnauthenticatedSessionJson.populated(
        userId: params.email,
        identityId: params.email,
      );
      await Future.wait(
          [cacheLastUserId(params.email), localSessionJson.cache()]);
      return RegisterSuccess(localSessionJson.session, '');
    } else {
      return const RegisterKnownFailure(RegisterFailureType.userExists);
    }
  }

  @override
  Future<String?> resendConfirmationEmail(
    LocalUnauthenticatedSession session,
  ) async =>
      null;

  @override
  Future<SendForgotPasswordResponse> sendForgotPasswordRequest(
    String email,
  ) async {
    final existingUser = getLocalSessionJson(email);
    if (existingUser != null) {
      final newJson = LocalUnauthenticatedSessionJson.populated(
        userId: existingUser.userId,
        identityId: existingUser.identityId,
      );
      await Future.wait([cacheLastUserId(email), newJson.cache()]);
      return SendForgotPasswordSuccess(newJson.session);
    }
    return const SendForgotPasswordKnownFailure(
        SendForgotPasswordFailureType.noSuchUser);
  }

  @override
  Future<SubmitForgotPasswordFailure?> submitForgotPassword({
    required SubmitForgotPasswordParams params,
    required LocalUnauthenticatedSession session,
  }) async {
    final existingUser = getLocalSessionJson(params.email);
    if (existingUser != null) {
      final localSessionJson = LocalSessionJson.populated(
        userId: existingUser.userId,
        identityId: existingUser.identityId,
      );
      await Future.wait(
          [cacheLastUserId(params.email), localSessionJson.cache()]);
      return null;
    }
    return SubmitForgotPasswordFailure.noSuchUser;
  }
}
