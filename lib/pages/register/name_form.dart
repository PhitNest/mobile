import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../util/validators/validators.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';
import 'bloc.dart';

final class NamePage extends StatelessWidget {
  final RegisterControllers controllers;

  const NamePage({
    super.key,
    required this.controllers,
  }) : super();

  void onSubmit(BuildContext context) {
    if ((context.registerFormBloc.controllers.formKey.currentState
            ?.validate()) ??
        false) {
      controllers.pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          Text(
            'Let\'s get started!\nWhat is your name?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          StyledUnderlinedTextField(
            hint: 'First name',
            controller: controllers.firstNameController,
            validator: validateNonEmpty,
            textInputAction: TextInputAction.next,
          ),
          StyledUnderlinedTextField(
            hint: 'Last name',
            controller: controllers.lastNameController,
            validator: validateNonEmpty,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(context),
          ),
          ElevatedButton(
            onPressed: () => onSubmit(context),
            child: Text(
              'NEXT',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          RichText(
            text: TextSpan(
              text: 'Already registered?',
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
                TextSpan(
                  text: ' or ',
                  style: theme.textTheme.bodySmall,
                ),
                TextSpan(
                  text: 'Forgot Password',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                ),
              ],
            ),
          )
        ],
      );
}
