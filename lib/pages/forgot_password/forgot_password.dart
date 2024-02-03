import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../util/aws/aws.dart';
import '../../util/bloc/bloc.dart';
import '../../util/validators/validators.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';

part 'bloc.dart';

final class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key}) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ForgotPasswordProvider(
            createControllers: (_) => ForgotPasswordControllers(),
            createLoader: (_) => LoaderBloc(load: sendForgotPasswordRequest),
            createConsumer: (context, controllers, submit) => LoaderConsumer(
              listener: (context, loaderState) =>
                  _handleStateChanged(context, controllers, loaderState),
              builder: (context, loaderState) {
                final formBloc = context.formBloc<ForgotPasswordControllers>();
                return PageView(
                  controller: controllers.pageController,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          'Enter your email address',
                          style: theme.textTheme.bodyMedium,
                        ),
                        StyledUnderlinedTextField(
                          hint: 'Email',
                          controller: controllers.emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              formBloc.formKey.currentState!.validate()
                                  ? controllers.pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    )
                                  : {},
                          validator: EmailValidator.validateEmail,
                        ),
                        StyledOutlineButton(
                          onPress: () => controllers.pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          text: 'NEXT',
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          'Enter your new password',
                          style: theme.textTheme.bodyMedium,
                        ),
                        StyledPasswordField(
                          hint: 'New Password',
                          controller: controllers.newPasswordController,
                          textInputAction: TextInputAction.next,
                          validator: validatePassword,
                        ),
                        StyledPasswordField(
                          hint: 'Confirm Password',
                          controller: controllers.confirmPasswordController,
                          textInputAction: TextInputAction.done,
                          validator: (pass) =>
                              validatePassword(pass) ??
                              (pass != controllers.newPasswordController.text
                                  ? 'Passwords do not match'
                                  : null),
                          onFieldSubmitted: (_) => submit(
                              controllers.emailController.text, loaderState),
                        ),
                        Center(
                          child: switch (loaderState) {
                            LoaderLoadingState() =>
                              const CircularProgressIndicator(),
                            _ => ElevatedButton(
                                onPressed: () => submit(
                                    controllers.emailController.text,
                                    loaderState),
                                child: Text(
                                  'RESET PASSWORD',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                          },
                        ),
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
                                    Navigator.of(context).pushAndRemoveUntil(
                                      CupertinoPageRoute<void>(
                                        builder: (context) =>
                                            const RegisterPage(),
                                      ),
                                      (_) => false,
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Remembered your password?',
                            style: theme.textTheme.bodySmall,
                            children: [
                              TextSpan(
                                text: ' Login',
                                style: theme.textTheme.bodySmall!.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      CupertinoPageRoute<void>(
                                        builder: (context) => const LoginPage(),
                                      ),
                                      (_) => false,
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}
