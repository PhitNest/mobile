import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../util/validators/validators.dart';
import '../../widgets/widgets.dart';
import 'bloc.dart';

final class AccountInfoPage extends StatelessWidget {
  final RegisterControllers controllers;
  final void Function() onSubmit;
  final bool loading;

  const AccountInfoPage({
    super.key,
    required this.controllers,
    required this.onSubmit,
    required this.loading,
  }) : super();

  @override
  Widget build(BuildContext context) => ListView(
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
            validator: (value) => value == controllers.passwordController.text
                ? null
                : 'Passwords do not match',
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          if (loading)
            const Loader()
          else
            ElevatedButton(
              onPressed: onSubmit,
              child: Text(
                'SUBMIT',
                style: theme.textTheme.bodySmall,
              ),
            )
        ],
      );
}
