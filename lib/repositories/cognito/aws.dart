import 'package:amazon_cognito_identity_dart_2/cognito.dart';

import '../../config/aws.dart';
import '../../entities/entities.dart';

import '../../util/cache/cache.dart';
import '../../util/logger.dart';
import 'cognito.dart';

final class SecureCognitoStorage extends CognitoStorage {
  final Set<String> keyList = {};

  @override
  Future<void> clear() async {
    for (final key in keyList) {
      await cacheSecureString(key, null);
    }
  }

  @override
  Future<String?> getItem(String key) async {
    keyList.add(key);
    return getSecureCachedString(key);
  }

  @override
  Future<String?> removeItem(String key) async {
    keyList.remove(key);
    final res = getSecureCachedString(key);
    await cacheSecureString(key, null);
    return res;
  }

  @override
  Future<void> setItem(String key, covariant String? value) {
    keyList.add(key);
    return cacheSecureString(key, value);
  }
}

CognitoUserPool userPool = CognitoUserPool(
  kUserPoolId,
  kClientId,
  storage: SecureCognitoStorage(),
);

Future<RefreshSessionResponse> _handleRefreshFailures(
  Future<RefreshSessionResponse> Function() refresher,
) async {
  try {
    return await refresher();
  } on CognitoClientException catch (e) {
    error(e.toString());
    return switch (e.code) {
      'ResourceNotFoundException' => const RefreshSessionKnownFailure(
          RefreshSessionFailureType.invalidUserPool),
      'NotAuthorizedException' => const RefreshSessionKnownFailure(
          RefreshSessionFailureType.invalidToken),
      'UserNotFoundException' =>
        const RefreshSessionKnownFailure(RefreshSessionFailureType.noSuchUser),
      _ => RefreshSessionUnknownFailure(message: e.message),
    };
  } on ArgumentError catch (e) {
    error(e.toString());
    return const RefreshSessionKnownFailure(
        RefreshSessionFailureType.invalidUserPool);
  } catch (e) {
    await logError(e.toString());
    return RefreshSessionUnknownFailure(message: e.toString());
  }
}

final class AwsCognito extends Cognito<AwsUnauthenticatedSession, AwsSession> {
  const AwsCognito() : super();

  @override
  Future<ChangePasswordResponse> changePassword({
    required String newPassword,
    required AwsUnauthenticatedSession unauthenticatedSession,
  }) async {
    try {
      final session =
          await unauthenticatedSession.user.sendNewPasswordRequiredAnswer(
        newPassword,
      );
      if (session != null) {
        final credentials = CognitoCredentials(
          kIdentityPoolId,
          unauthenticatedSession.user.pool,
        );
        await credentials.getAwsCredentials(
          session.getIdToken().getJwtToken(),
        );
        return ChangePasswordSuccess(
          AwsSession(
            user: unauthenticatedSession.user,
            cognitoSession: session,
            credentials: credentials,
          ),
        );
      } else {
        return const ChangePasswordUnknownFailure(message: null);
      }
    } on CognitoClientException catch (e) {
      error(e.toString());
      return switch (e.code) {
        'ResourceNotFoundException' => const ChangePasswordKnownFailure(
            ChangePasswordFailureType.invalidUserPool,
          ),
        'NotAuthorizedException' => const ChangePasswordKnownFailure(
            ChangePasswordFailureType.invalidPassword,
          ),
        'UserNotFoundException' => const ChangePasswordKnownFailure(
            ChangePasswordFailureType.noSuchUser,
          ),
        _ => ChangePasswordUnknownFailure(message: e.message),
      };
    } on ArgumentError catch (err) {
      await logError(err.toString(),
          userId: unauthenticatedSession.user.username);
      return const ChangePasswordKnownFailure(
        ChangePasswordFailureType.invalidUserPool,
      );
    } catch (err) {
      await logError(err.toString(),
          userId: unauthenticatedSession.user.username);
      return ChangePasswordUnknownFailure(message: err.toString());
    }
  }

  @override
  Future<String?> confirmEmail({
    required AwsUnauthenticatedSession session,
    required String code,
  }) async {
    try {
      if (await session.user.confirmRegistration(code)) {
        return null;
      } else {
        return 'Failed to confirm email';
      }
    } on CognitoClientException catch (e) {
      final errorMessage = e.message ?? e.toString();
      await logError(errorMessage, userId: session.user.username);
      return errorMessage;
    }
  }

  @override
  Future<bool> deleteAccount(AwsSession session) => session.user.deleteUser();

  @override
  Future<RefreshSessionResponse> getPreviousSession() async {
    return await _handleRefreshFailures(
      () async {
        final user = await userPool.getCurrentUser();
        if (user != null) {
          final session = await user.getSession();
          if (session != null) {
            final credentials = CognitoCredentials(
              kIdentityPoolId,
              userPool,
            );
            await credentials
                .getAwsCredentials(session.getIdToken().getJwtToken());
            return RefreshSessionSuccess(
              AwsSession(
                user: user,
                cognitoSession: session,
                credentials: credentials,
              ),
            );
          }
        }
        return const RefreshSessionUnknownFailure(message: null);
      },
    );
  }

  @override
  Future<LoginResponse> login(LoginParams params) async {
    final user = CognitoUser(params.email, userPool);
    try {
      final session = await user.authenticateUser(
        AuthenticationDetails(
          username: params.email.toLowerCase(),
          password: params.password,
        ),
      );
      if (session != null) {
        final userId = session.accessToken.getSub();
        if (userId != null) {
          final credentials = CognitoCredentials(kIdentityPoolId, userPool);
          await credentials
              .getAwsCredentials(session.getIdToken().getJwtToken());
          return LoginSuccess(
            session: AwsSession(
              user: user,
              cognitoSession: session,
              credentials: credentials,
            ),
          );
        }
      }
      await logError('Failed to login', userId: user.username);
      return const LoginUnknownResponse(message: null);
    } on CognitoUserConfirmationNecessaryException catch (e) {
      error(e.toString());
      return LoginConfirmationRequired(
          session: AwsUnauthenticatedSession(user: user),
          password: params.password);
    } on CognitoClientException catch (e) {
      error(e.toString());
      return switch (e.code) {
        'ResourceNotFoundException' =>
          const LoginKnownFailure(LoginFailureType.invalidUserPool),
        'NotAuthorizedException' =>
          const LoginKnownFailure(LoginFailureType.invalidEmailPassword),
        'UserNotFoundException' =>
          const LoginKnownFailure(LoginFailureType.noSuchUser),
        _ => LoginUnknownResponse(message: e.message),
      };
    } on ArgumentError catch (e) {
      await logError(e.toString(), userId: user.username);
      return const LoginKnownFailure(LoginFailureType.invalidUserPool);
    } on CognitoUserNewPasswordRequiredException catch (e) {
      error(e.toString());
      return LoginChangePasswordRequired(AwsUnauthenticatedSession(user: user));
    } catch (err) {
      await logError(err.toString(), userId: user.username);
      return LoginUnknownResponse(message: err.toString());
    }
  }

  @override
  Future<void> logout(AwsSession session) => session.user.signOut();

  @override
  Future<RefreshSessionResponse> refreshSession(AwsSession session) async {
    return await _handleRefreshFailures(
      () async {
        final newUserSession = await session.user
            .refreshSession(session.cognitoSession.refreshToken!);
        if (newUserSession != null) {
          await session.credentials.getAwsCredentials(
              session.cognitoSession.getIdToken().getJwtToken());
          return RefreshSessionSuccess(
            AwsSession(
              user: session.user,
              cognitoSession: newUserSession,
              credentials: session.credentials,
            ),
          );
        }
        await logError('Failed to refresh session',
            userId: session.user.username);
        return const RefreshSessionUnknownFailure(message: null);
      },
    );
  }

  @override
  Future<RegisterResponse> register(RegisterParams params) async {
    try {
      final signUpResult = await userPool.signUp(
        params.email,
        params.password,
        userAttributes: [
          AttributeArg(name: 'email', value: params.email),
        ],
        validationData: [
          AttributeArg(name: 'firstName', value: params.firstName),
          AttributeArg(name: 'lastName', value: params.lastName),
        ],
      );
      if (signUpResult.userSub != null) {
        return RegisterSuccess(
          AwsUnauthenticatedSession(user: signUpResult.user),
          params.password,
        );
      } else {
        await logError('Failed to register', userId: params.email);
        return const RegisterUnknownFailure(message: null);
      }
    } on CognitoClientException catch (e) {
      error(e.toString());
      return switch (e.code) {
        'ResourceNotFoundException' =>
          const RegisterKnownFailure((RegisterFailureType.invalidUserPool)),
        'UsernameExistsException' =>
          const RegisterKnownFailure(RegisterFailureType.userExists),
        'InvalidPasswordException' => ValidationFailure(
            e.message ?? 'Invalid password',
          ),
        'InvalidParameterException' =>
          ValidationFailure(e.message ?? 'Invalid email'),
        _ => RegisterUnknownFailure(message: e.message),
      };
    } on ArgumentError catch (e) {
      await logError(e.toString(), userId: params.email);
      return const RegisterKnownFailure(RegisterFailureType.invalidUserPool);
    } catch (e) {
      await logError(e.toString(), userId: params.email);
      return RegisterUnknownFailure(message: e.toString());
    }
  }

  @override
  Future<SendForgotPasswordResponse> sendForgotPasswordRequest(
    String email,
  ) async {
    try {
      final user = CognitoUser(email, userPool);
      await user.forgotPassword();
      return SendForgotPasswordSuccess(AwsUnauthenticatedSession(user: user));
    } on CognitoClientException catch (e) {
      error(e.toString());
      return switch (e.code) {
        'ResourceNotFoundException' => const SendForgotPasswordKnownFailure(
            SendForgotPasswordFailureType.invalidUserPool),
        'InvalidParameterException' => const SendForgotPasswordKnownFailure(
            SendForgotPasswordFailureType.invalidEmail),
        'UserNotFoundException' => const SendForgotPasswordKnownFailure(
            SendForgotPasswordFailureType.noSuchUser),
        _ => SendForgotPasswordUnknownFailure(message: e.message),
      };
    } on ArgumentError catch (e) {
      error(e.toString());
      return const SendForgotPasswordKnownFailure(
        SendForgotPasswordFailureType.invalidUserPool,
      );
    } catch (e) {
      await logError(e.toString(), userId: email);
      return SendForgotPasswordUnknownFailure(message: e.toString());
    }
  }

  @override
  Future<SubmitForgotPasswordFailure?> submitForgotPassword({
    required SubmitForgotPasswordParams params,
    required AwsUnauthenticatedSession session,
  }) async {
    try {
      if (await session.user.confirmPassword(params.code, params.newPassword)) {
        return null;
      } else {
        return SubmitForgotPasswordFailure.invalidCode;
      }
    } on CognitoClientException catch (e) {
      error(e.toString());
      return switch (e.code) {
        'ResourceNotFoundException' =>
          SubmitForgotPasswordFailure.invalidUserPool,
        'InvalidParameterException' =>
          SubmitForgotPasswordFailure.invalidCodeOrPassword,
        'CodeMismatchException' => SubmitForgotPasswordFailure.invalidCode,
        'ExpiredCodeException' => SubmitForgotPasswordFailure.expiredCode,
        'UserNotFoundException' => SubmitForgotPasswordFailure.noSuchUser,
        _ => SubmitForgotPasswordFailure.unknown,
      };
    } catch (e) {
      await logError(e.toString(), userId: session.user.username);
      return SubmitForgotPasswordFailure.unknown;
    }
  }

  @override
  Future<String?> resendConfirmationEmail(
      AwsUnauthenticatedSession session) async {
    try {
      await session.user.resendConfirmationCode();
      return null;
    } catch (e) {
      await logError(e.toString(), userId: session.user.username);
      return e.toString();
    }
  }
}
