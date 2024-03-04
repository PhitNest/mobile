import 'package:flutter/cupertino.dart';

import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../util/util.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';
import 'bloc.dart';
import 'login_form.dart';

final class LoginProviderWidget extends StatelessWidget {
  const LoginProviderWidget({super.key}) : super();

  @override
  Widget build(BuildContext context) => LoginProvider(
        createControllers: (_) => LoginControllers(),
        createLoader: loginBloc,
        createConsumer: (context, controllers, submit) => LoaderConsumer(
          listener: (context, loaderState) => loaderState.loaded(
            (response) => switch (response) {
              LoginSuccess() => Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute<void>(
                    builder: (_) => const HomePage(),
                  ),
                  (_) => false,
                ),
              LoginConfirmationRequired(session: final session) =>
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute<void>(
                    builder: (context) => VerificationPage(
                      session: session,
                      resend: (session) => resendConfirmationEmail(session),
                      confirm: (session, code) => confirmEmail(
                        session: session,
                        code: code,
                      ),
                      loginParams: LoginParams(
                        email: controllers.emailController.text,
                        password: controllers.passwordController.text,
                      ),
                    ),
                  ),
                ),
              LoginFailureResponse(message: final message) ||
              LoginUnknownResponse(message: final message) ||
              LoginChangePasswordRequired(message: final message) =>
                StyledBanner.show(
                  message: message,
                  error: true,
                ),
            },
          ),
          builder: (context, loaderState) => LoginForm(
            controllers: controllers,
            loading: loaderState.isLoading,
            submit: () => submit(
              LoginParams(
                email: controllers.emailController.text,
                password: controllers.passwordController.text,
              ),
              loaderState,
            ),
          ),
        ),
      );
}
