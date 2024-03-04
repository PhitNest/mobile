import 'package:flutter/material.dart';

import 'account_info_form.dart';
import 'bloc.dart';
import 'name_form.dart';

final class RegisterForms extends StatelessWidget {
  final RegisterControllers controllers;
  final bool loading;
  final VoidCallback submit;

  const RegisterForms({
    super.key,
    required this.controllers,
    required this.submit,
    required this.loading,
  }) : super();

  @override
  Widget build(BuildContext context) => PageView(
        controller: controllers.pageController,
        children: [
          NamePage(
            controllers: controllers,
          ),
          AccountInfoPage(
            controllers: controllers,
            loading: loading,
            onSubmit: submit,
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
      );
}
