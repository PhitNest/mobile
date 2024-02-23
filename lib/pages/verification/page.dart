import 'package:flutter/material.dart';

import '../../entities/entities.dart';
import 'provider.dart';
import 'verification_form.dart';

final class VerificationPage extends StatelessWidget {
  final LoginParams loginParams;
  final UnauthenticatedSession session;

  final Future<String?> Function(UnauthenticatedSession session) resend;
  final Future<String?> Function(UnauthenticatedSession session, String code)
      confirm;

  /// Verifies the user's email address, and then logs them in after a
  /// successful verification.
  ///
  /// The [loginParams] are used to log the user in after a successful
  /// verification.
  ///
  /// The [session] is the session that needs to be verified.
  ///
  /// The [resend] function is used to resend the verification code.
  ///
  /// The [confirm] function is used to confirm the verification code.
  const VerificationPage({
    super.key,
    required this.loginParams,
    required this.session,
    required this.resend,
    required this.confirm,
  }) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: VerificationStateProvider(
            confirm: confirm,
            resend: resend,
            loginParams: loginParams,
            session: session,
            builder: (context, controllers, loginState, resendState, submit) =>
                VerificationForm(
              controllers: controllers,
              loginState: loginState,
              resendState: resendState,
              session: session,
              submit: submit,
            ),
          ),
        ),
      );
}
