import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entities/entities.dart';
import '../../repositories/cognito/cognito.dart';
import '../../theme.dart';
import '../../util/bloc/bloc.dart';
import '../../util/validators/validators.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';

part 'bloc.dart';

final class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key}) : super();

  @override
  Widget build(BuildContext context) => _RegisterProvider(
        createControllers: (_) => _RegisterControllers(),
        createLoader: (_) => LoaderBloc(load: register),
        createConsumer: (context, controllers, submit) => LoaderConsumer(
          listener: (context, loaderState) =>
              _handleState(context, controllers, loaderState),
          builder: (context, loaderState) => loaderState.loaderOr(
            PageView(
              controller: controllers.pageController,
              children: [
                _NamePage(
                  controllers: controllers,
                ),
                _AccountInfoPage(
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

final class _AccountInfoPage extends StatelessWidget {
  final _RegisterControllers controllers;
  final void Function() onSubmit;

  const _AccountInfoPage({
    required this.controllers,
    required this.onSubmit,
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

final class _NamePage extends StatelessWidget {
  final _RegisterControllers controllers;

  const _NamePage({
    required this.controllers,
  }) : super();

  void onSubmit(BuildContext context) {
    if ((context.registerFormBloc.formKey.currentState?.validate()) ?? false) {
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
                    ..onTap = () {
                      Navigator.of(context).pushReplacement(
                        CupertinoPageRoute<void>(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
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
                          builder: (context) => const ForgotPasswordScreen(),
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
