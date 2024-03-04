import 'package:flutter/cupertino.dart';

import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../util/util.dart';
import '../../widgets/widgets.dart';

final class ForgotPasswordControllers extends FormControllers {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final pageController = PageController();

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    pageController.dispose();
  }
}

typedef ForgotPasswordProvider = FormProvider<ForgotPasswordControllers, String,
    SendForgotPasswordResponse>;

LoaderBloc<String, SendForgotPasswordResponse> sendForgotPasswordBloc(
  BuildContext context,
) =>
    LoaderBloc(load: sendForgotPasswordRequest);
