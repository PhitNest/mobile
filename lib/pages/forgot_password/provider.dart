import 'package:flutter/cupertino.dart';

import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../util/util.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';
import 'bloc.dart';
import 'forgot_password_form.dart';

final class ForgotPasswordProviderWidget extends StatelessWidget {
  const ForgotPasswordProviderWidget({super.key}) : super();

  @override
  Widget build(BuildContext context) => ForgotPasswordProvider(
        createControllers: (_) => ForgotPasswordControllers(),
        createLoader: sendForgotPasswordBloc,
        createConsumer: (context, controllers, submit) => LoaderConsumer(
          listener: (context, loaderState) => loaderState.loaded(
            (response) => switch (response) {
              SendForgotPasswordSuccess(session: final session) =>
                Navigator.push(
                  context,
                  CupertinoPageRoute<void>(
                    builder: (context) => VerificationPage(
                      loginParams: LoginParams(
                        email: controllers.emailController.text,
                        password: controllers.newPasswordController.text,
                      ),
                      session: session,
                      resend: (session) => sendForgotPasswordRequest(
                        controllers.emailController.text,
                      ).then(
                        (state) => switch (state) {
                          SendForgotPasswordSuccess() => null,
                          SendForgotPasswordFailureResponse(
                            message: final message
                          ) =>
                            message,
                        },
                      ),
                      confirm: (session, code) => submitForgotPassword(
                        params: SubmitForgotPasswordParams(
                          email: controllers.emailController.text,
                          code: code,
                          newPassword: controllers.newPasswordController.text,
                        ),
                        session: session,
                      ).then((state) => state?.message),
                    ),
                  ),
                ),
              SendForgotPasswordFailureResponse(message: final message) =>
                StyledBanner.show(message: message, error: true),
            },
          ),
          builder: (context, loaderState) => ForgotPasswordForm(
            controllers: controllers,
            loading: loaderState.isLoading,
            submit: () => submit(controllers.emailController.text, loaderState),
          ),
        ),
      );
}
