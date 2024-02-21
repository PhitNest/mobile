import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../entities/entities.dart';
import '../../repositories/cognito/cognito.dart';
import '../../theme.dart';
import '../../util/bloc/bloc.dart';
import '../../widgets/widgets.dart';
import '../home/home.dart';

part 'bloc.dart';
part 'verification_field.dart';

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

  /// Submits the verification code and logs the user in if the verification
  /// is successful.
  Future<LoginResponse> confirmAndLogin(String code) async {
    final error = await confirm(session, code);
    if (error == null) {
      return await login(loginParams);
    } else {
      return LoginUnknownResponse(message: error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: _StateProvider(
            confirmAndLogin: confirmAndLogin,
            resend: resend,
            builder: (
              context,
              submit,
              controllers,
              loginState,
              resendState,
            ) =>
                ListView(
              children: [
                Text(
                  'Verify your email',
                  style: theme.textTheme.bodyLarge,
                ),
                _VerificationField(
                  onCompleted: () => resendState.handle(
                    loading: () {},
                    fallback: () {
                      submit();
                      final currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                  ),
                  controllers: controllers,
                ),
                ...loginState.loaderOrList(
                  resendState.loaderOrList(
                    [
                      ElevatedButton(
                        onPressed: submit,
                        child: Text(
                          'CONFIRM',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.resendEmailLoaderBloc
                            .add(LoaderLoadEvent(session)),
                        child: Text(
                          'RESEND',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

final class _StateProvider extends StatelessWidget {
  final Future<LoginResponse> Function(String code) confirmAndLogin;
  final Future<String?> Function(UnauthenticatedSession session) resend;
  final Widget Function(
    BuildContext context,
    VoidCallback submit,
    _VerificationControllers controllers,
    LoaderState<LoginResponse> loginState,
    LoaderState<String?> resendState,
  ) builder;

  /// Provides and handles the state for the verification page.
  ///
  /// The [confirmAndLogin] function is used to confirm the verification code
  /// and log the user in.
  ///
  /// The [resend] function is used to resend the verification code.
  ///
  /// The [builder] is used to build the UI from the state.
  const _StateProvider({
    required this.confirmAndLogin,
    required this.resend,
    required this.builder,
  }) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => _ResendLoaderBloc(load: resend),
        child: _VerificationProvider(
          createLoader: (_) => LoaderBloc(load: confirmAndLogin),
          createControllers: (_) => _VerificationControllers(),
          createConsumer: (context, controllers, submit) => LoaderConsumer(
            listener: (context, loginState) =>
                _handleConfirmState(context, controllers, loginState),
            builder: (context, loginState) => _ResendLoaderConsumer(
              listener: _handleResendState,
              builder: (context, resendState) => builder(
                context,
                () => submit(controllers.codeController.text, loginState),
                controllers,
                loginState,
                resendState,
              ),
            ),
          ),
        ),
      );
}
