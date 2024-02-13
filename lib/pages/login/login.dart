import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../entities/entities.dart';
import '../../repositories/cognito/cognito.dart';
import '../../theme.dart';
import '../../util/bloc/bloc.dart';
import '../../util/validators/validators.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';

part 'bloc.dart';

LoginParams _params(LoginControllers controllers) => LoginParams(
      email: controllers.emailController.text,
      password: controllers.passwordController.text,
    );

final class LoginPage extends StatelessWidget {
  const LoginPage({super.key}) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Container(
              height: constraints.maxHeight,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LoginProvider(
                createControllers: (_) => LoginControllers(),
                createLoader: (_) => LoaderBloc(load: login),
                createConsumer: (context, controllers, submit) =>
                    LoaderConsumer(
                  listener: (context, loaderState) =>
                      _handleStateChanged(context, controllers, loaderState),
                  builder: (context, loaderState) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: theme.textTheme.bodyLarge,
                      ),
                      StyledUnderlinedTextField(
                        hint: 'Email',
                        controller: controllers.emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: EmailValidator.validateEmail,
                      ),
                      StyledPasswordField(
                        hint: 'Password',
                        controller: controllers.passwordController,
                        textInputAction: TextInputAction.done,
                        validator: validatePassword,
                        onFieldSubmitted: (_) =>
                            submit(_params(controllers), loaderState),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              context.loginBloc.add(const LoaderCancelEvent());
                              Navigator.push(
                                context,
                                CupertinoPageRoute<void>(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: theme.textTheme.bodySmall!
                                  .copyWith(fontStyle: FontStyle.normal),
                            ),
                          ),
                        ],
                      ),
                      switch (loaderState) {
                        LoaderLoadingState() =>
                          const CircularProgressIndicator(),
                        LoaderInitialState() ||
                        LoaderLoadedState() =>
                          ElevatedButton(
                            onPressed: () =>
                                submit(_params(controllers), loaderState),
                            child: Text(
                              'LOGIN',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                      },
                      RichText(
                        text: TextSpan(
                          text: "Don't have an account?",
                          style: theme.textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: ' Register',
                              style: theme.textTheme.bodySmall!.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.loginBloc
                                      .add(const LoaderCancelEvent());
                                  Navigator.of(context).pushReplacement(
                                    CupertinoPageRoute<void>(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
