import 'package:flutter/cupertino.dart';

import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../util/util.dart';
import '../../widgets/widgets.dart';

final class LoginControllers extends FormControllers {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}

extension LoginBlocGetter on BuildContext {
  LoaderBloc<LoginParams, LoginResponse> get loginBloc => loader();
}

typedef LoginProvider
    = FormProvider<LoginControllers, LoginParams, LoginResponse>;

LoaderBloc<LoginParams, LoginResponse> loginBloc(BuildContext context) =>
    LoaderBloc(load: login);
