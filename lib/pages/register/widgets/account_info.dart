import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../../util/validators/validators.dart';
import '../../../widgets/widgets.dart';
import '../register.dart';

final class RegisterAccountInfoPage extends StatelessWidget {
  final RegisterControllers controllers;
  final void Function() onSubmit;

  const RegisterAccountInfoPage({
    super.key,
    required this.controllers,
    required this.onSubmit,
  }) : super();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Let\'s create your account!',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                StyledUnderlinedTextField(
                  hint: 'Your email address',
                  controller: controllers.emailController,
                  validator: EmailValidator.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                StyledPasswordField(
                  hint: 'Password',
                  controller: controllers.passwordController,
                  validator: validatePassword,
                  textInputAction: TextInputAction.next,
                ),
                StyledPasswordField(
                  hint: 'Confirm password',
                  validator: (value) =>
                      value == controllers.passwordController.text
                          ? null
                          : 'Passwords do not match',
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => onSubmit(),
                ),
                ElevatedButton(
                  onPressed: onSubmit,
                  child: Text(
                    'SUBMIT',
                    style: theme.textTheme.bodySmall,
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
