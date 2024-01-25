import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme.dart';
import '../../util/aws/aws.dart';
import '../../util/bloc/bloc.dart';
import '../../widgets/widgets.dart';
import '../home/home.dart';
import 'widgets/widgets.dart';

part 'bloc.dart';

final class VerificationPage extends StatelessWidget {
  final LoginParams loginParams;
  final UnauthenticatedSession unauthenticatedSession;
  final Future<String?> Function(UnauthenticatedSession session) resend;
  final Future<String?> Function(UnauthenticatedSession session, String code)
      confirm;

  const VerificationPage({
    super.key,
    required this.loginParams,
    required this.unauthenticatedSession,
    required this.resend,
    required this.confirm,
  }) : super();

  Future<LoginResponse> _confirmAndLogin(String code) async {
    final error = await confirm(unauthenticatedSession, code);
    if (error == null) {
      return await login(loginParams);
    } else {
      return LoginUnknownResponse(message: error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: BlocProvider(
                create: (_) => ResendLoaderBloc(load: resend),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Verify your email',
                      style: theme.textTheme.bodyLarge,
                    ),
                    Center(
                      child: FormProvider(
                        createLoader: (_) => LoaderBloc(load: _confirmAndLogin),
                        createControllers: (_) => VerificationControllers(),
                        createConsumer: (context, controllers, submit) =>
                            LoaderConsumer(
                          listener: (context, loaderState) =>
                              _handleConfirmStateChanged(
                                  context, controllers, loaderState),
                          builder: (context, loaderState) =>
                              ResendLoaderConsumer(
                            listener: _handleResendStateChanged,
                            builder: (context, resendState) => Column(
                              children: [
                                VerificationField(
                                  controller: controllers.codeController,
                                  focusNode: controllers.focusNode,
                                  onChanged: (value) {},
                                  onCompleted: switch (resendState) {
                                    LoaderLoadingState() => (_) {},
                                    _ => (code) {
                                        submit(code, loaderState);
                                        final currentFocus =
                                            FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                      }
                                  },
                                ),
                                ...switch (loaderState) {
                                  LoaderLoadingState() => [const Loader()],
                                  _ => switch (resendState) {
                                      LoaderLoadingState() => [const Loader()],
                                      _ => [
                                          ElevatedButton(
                                            onPressed: () => submit(
                                              controllers.codeController.text,
                                              loaderState,
                                            ),
                                            child: Text(
                                              'CONFIRM',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => context
                                                .resendEmailLoaderBloc
                                                .add(LoaderLoadEvent(
                                                    unauthenticatedSession)),
                                            child: Text(
                                              'RESEND',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                    },
                                },
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
