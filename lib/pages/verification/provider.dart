import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../util/bloc/bloc.dart';
import '../../widgets/widgets.dart';
import '../home/home.dart';
import 'bloc.dart';

final class VerificationStateProvider extends StatelessWidget {
  final LoginParams loginParams;
  final UnauthenticatedSession session;

  final Future<String?> Function(UnauthenticatedSession session, String code)
      confirm;
  final Future<String?> Function(UnauthenticatedSession session) resend;

  final Widget Function(
    BuildContext context,
    VerificationControllers controllers,
    LoaderState<LoginResponse> loginState,
    LoaderState<String?> resendState,
    VoidCallback submit,
  ) builder;

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

  /// Provides and handles the state for the verification page.
  ///
  /// The [confirmAndLogin] function is used to confirm the verification code
  /// and log the user in.
  ///
  /// The [resend] function is used to resend the verification code.
  ///
  /// The [builder] is used to build the UI from the state.
  const VerificationStateProvider({
    super.key,
    required this.confirm,
    required this.loginParams,
    required this.session,
    required this.resend,
    required this.builder,
  }) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ResendLoaderBloc(load: resend),
        child: VerificationProvider(
          createLoader: (_) => LoaderBloc(load: confirmAndLogin),
          createControllers: (_) => VerificationControllers(),
          createConsumer: (context, controllers, submit) => LoaderConsumer(
            listener: (context, loginState) {
              loginState.handle(
                loaded: (response) {
                  switch (response) {
                    case LoginSuccess():
                      Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoPageRoute<void>(
                          builder: (_) => const HomePage(),
                        ),
                        (_) => false,
                      );
                    case LoginFailureResponse(message: final message):
                      StyledBanner.show(message: message, error: true);
                      controllers.codeController.clear();
                  }
                },
                fallback: () {},
              );
            },
            builder: (context, loginState) => ResendLoaderConsumer(
              listener: (context, resendEmailState) => resendEmailState.handle(
                loaded: (error) => StyledBanner.show(
                  message: error ?? 'Email resent',
                  error: error != null,
                ),
                fallback: () {},
              ),
              builder: (context, resendState) => builder(
                context,
                controllers,
                loginState,
                resendState,
                () => submit(controllers.codeController.text, loginState),
              ),
            ),
          ),
        ),
      );
}
