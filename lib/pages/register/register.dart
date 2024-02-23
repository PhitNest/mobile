import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../entities/entities.dart';
import '../../repositories/cognito/cognito.dart';
import '../../util/bloc/bloc.dart';
import '../../widgets/widgets.dart';
import '../verification/page.dart';
import 'account_info_form.dart';
import 'bloc.dart';
import 'name_form.dart';

final class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key}) : super();

  @override
  Widget build(BuildContext context) => RegisterProvider(
        createControllers: (_) => RegisterControllers(),
        createLoader: (_) => LoaderBloc(load: register),
        createConsumer: (context, controllers, submit) => LoaderConsumer(
          listener: (context, registerFormState) => registerFormState.handle(
            loaded: (response) => switch (response) {
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
            fallback: () {},
          ),
          builder: (context, loaderState) => loaderState.loaderOr(
            PageView(
              controller: controllers.pageController,
              children: [
                NamePage(
                  controllers: controllers,
                ),
                AccountInfoPage(
                  controllers: controllers,
                  onSubmit: () => submit(
                    RegisterParams(
                      email: controllers.emailController.text,
                      password: controllers.passwordController.text,
                      firstName: controllers.firstNameController.text,
                      lastName: controllers.lastNameController.text,
                    ),
                    loaderState,
                  ),
                ),
              ]
                  .map(
                    (page) => Scaffold(
                      body: Align(
                        alignment: Alignment.center,
                        child: page,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      );
}
