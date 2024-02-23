import 'package:flutter/material.dart';

import '../../entities/cognito/cognito.dart';
import '../../entities/session/session.dart';
import '../../util/bloc/bloc.dart';
import '../../widgets/providers/providers.dart';

class VerificationControllers extends FormControllers {
  final focusNode = FocusNode();
  final codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    focusNode.dispose();
  }
}

typedef ResendLoaderBloc = LoaderBloc<UnauthenticatedSession, String?>;
typedef ResendLoaderConsumer = LoaderConsumer<UnauthenticatedSession, String?>;

extension ResendEmailBloc on BuildContext {
  ResendLoaderBloc get resendEmailLoaderBloc => loader();
}

typedef VerificationProvider
    = FormProvider<VerificationControllers, String, LoginResponse>;
