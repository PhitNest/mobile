import 'package:flutter/material.dart';

import '../../../util/validators/validators.dart';
import '../../../widgets/widgets.dart';
import '../register.dart';

final class RegisterNamePage extends StatelessWidget {
  final RegisterControllers controllers;
  final void Function() onSubmit;

  const RegisterNamePage({
    super.key,
    required this.controllers,
    required this.onSubmit,
  }) : super();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                onFieldSubmitted: (_) => onSubmit(),
              ),
              ElevatedButton(
                onPressed: onSubmit,
                child: Text(
                  'NEXT',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            ],
          ),
        ),
      );
}
