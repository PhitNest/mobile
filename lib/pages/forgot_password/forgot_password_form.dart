import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import '../../theme.dart';
import '../../util/util.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';
import 'bloc.dart';

final class ForgotPasswordForm extends StatelessWidget {
  final ForgotPasswordControllers controllers;
  final VoidCallback submit;
  final bool loading;

  const ForgotPasswordForm({
    super.key,
    required this.controllers,
    required this.submit,
    required this.loading,
  }) : super();

  @override
  Widget build(BuildContext context) => PageView(
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
                    controllers.formKey.currentState!.validate()
                        ? controllers.pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
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
                onFieldSubmitted: (_) => submit(),
              ),
              if (loading)
                const Loader()
              else ...[
                Text(
                  'RESET PASSWORD',
                  style: theme.textTheme.bodySmall,
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
                                builder: (context) => const RegisterPage(),
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
                          ..onTap = () => goToLogin(context),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      );
}
