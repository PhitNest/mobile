import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entities/entities.dart';
import '../../repositories/cognito/cognito.dart';
import '../../util/bloc/bloc.dart';
import '../../widgets/widgets.dart';
import '../verification/verification.dart';
import 'widgets/widgets.dart';

part 'bloc.dart';

final class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key}) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: registerForm(
          (context, controllers, submit) => LoaderConsumer(
            listener: (context, loaderState) =>
                _handleStateChanged(context, controllers, loaderState),
            builder: (context, loaderState) {
              return switch (loaderState) {
                LoaderLoadingState() =>
                  const Center(child: CircularProgressIndicator()),
                _ => PageView(
                    controller: controllers.pageController,
                    children: [
                      RegisterNamePage(
                        controllers: controllers,
                        onSubmit: () {
                          if ((context.registerFormBloc.formKey.currentState
                                  ?.validate()) ??
                              false) {
                            controllers.pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                      RegisterAccountInfoPage(
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
                    ],
                  ),
              };
            },
          ),
        ),
      );
}
