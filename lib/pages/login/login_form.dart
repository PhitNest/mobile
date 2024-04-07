import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../theme.dart';
import '../../util/util.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';
import 'bloc.dart';

final class LoginForm extends StatelessWidget {
  final LoginControllers controllers;
  final VoidCallback submit;
  final bool loading;

  const LoginForm({
    super.key,
    required this.controllers,
    required this.submit,
    required this.loading,
  }) : super();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20.0),
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
            onFieldSubmitted: (_) => submit(),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.loginBloc.cancel();
                  Navigator.push(
                    context,
                    CupertinoPageRoute<void>(
                      builder: (context) => const ForgotPasswordPage(),
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
          if (loading)
            const Loader()
          else
            ElevatedButton(
              onPressed: submit,
              child: Text(
                'LOGIN',
                style: theme.textTheme.bodySmall,
              ),
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
                    ..onTap = () => Navigator.of(context).pushReplacement(
                          CupertinoPageRoute<void>(
                            builder: (context) => const RegisterPage(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      );
}
