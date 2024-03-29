import 'package:flutter/material.dart';

import '../../entities/cognito/cognito.dart';
import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../util/bloc/bloc.dart';
import '../../widgets/widgets.dart';

final class RegisterControllers extends FormControllers {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final pageController = PageController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    pageController.dispose();
  }
}

extension RegisterFormBloc on BuildContext {
  FormBloc<RegisterControllers> get registerFormBloc => formBloc();
}

typedef RegisterProvider
    = FormProvider<RegisterControllers, RegisterParams, RegisterResponse>;

LoaderBloc<RegisterParams, RegisterResponse> registerLoaderBloc(
  BuildContext context,
) =>
    LoaderBloc(load: (params) => register(params));
