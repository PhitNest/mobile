import 'package:flutter/cupertino.dart';

import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../util/util.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';
import 'bloc.dart';
import 'register_forms.dart';

final class RegisterProviderWidget extends StatelessWidget {
  const RegisterProviderWidget({super.key}) : super();

  @override
  Widget build(BuildContext context) => RegisterProvider(
        createControllers: (_) => RegisterControllers(),
        createLoader: registerLoaderBloc,
        createConsumer: (context, controllers, submit) => LoaderConsumer(
          listener: (context, registerFormState) => registerFormState.loaded(
            (response) => switch (response) {
              RegisterSuccess(session: final session) =>
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute<void>(
                    builder: (context) => VerificationPage(
                      loginParams: LoginParams(
                        email: controllers.emailController.text,
                        password: controllers.passwordController.text,
                      ),
                      resend: (session) => resendConfirmationEmail(session),
                      confirm: (session, code) =>
                          confirmEmail(session: session, code: code),
                      session: session,
                    ),
                  ),
                ),
              RegisterFailureResponse(message: final message) =>
                StyledBanner.show(message: message, error: true),
            },
          ),
          builder: (context, loaderState) => RegisterForms(
            controllers: controllers,
            submit: () => submit(
              RegisterParams(
                email: controllers.emailController.text,
                password: controllers.passwordController.text,
                firstName: controllers.firstNameController.text,
                lastName: controllers.lastNameController.text,
              ),
              loaderState,
            ),
            loading: loaderState.isLoading,
          ),
        ),
      );
}
