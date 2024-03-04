import 'package:flutter/material.dart';

import '../../entities/entities.dart';
import '../../theme.dart';
import '../../util/bloc/bloc.dart';
import '../../widgets/widgets.dart';
import 'bloc.dart';
import 'verification_field.dart';

final class VerificationForm extends StatelessWidget {
  final VoidCallback submit;
  final VerificationControllers controllers;
  final LoaderState<LoginResponse> loginState;
  final LoaderState<String?> resendState;
  final UnauthenticatedSession session;

  const VerificationForm({
    super.key,
    required this.submit,
    required this.controllers,
    required this.loginState,
    required this.resendState,
    required this.session,
  }) : super();

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          Text(
            'Verify your email',
            style: theme.textTheme.bodyLarge,
          ),
          VerificationField(
            onCompleted: () => resendState.handle(
              loading: () {},
              fallback: () {
                submit();
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
            ),
            controllers: controllers,
          ),
          if (loginState.isLoading || resendState.isLoading)
            const Loader()
          else ...[
            ElevatedButton(
              onPressed: submit,
              child: Text(
                'CONFIRM',
                style: theme.textTheme.bodySmall,
              ),
            ),
            ElevatedButton(
              onPressed: () => context.resendEmailLoaderBloc.load(session),
              child: Text(
                'RESEND',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ],
      );
}
