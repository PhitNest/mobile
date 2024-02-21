part of 'verification.dart';

class _VerificationControllers extends FormControllers {
  final focusNode = FocusNode();
  final codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    focusNode.dispose();
  }
}

typedef _ResendLoaderBloc = LoaderBloc<UnauthenticatedSession, String?>;
typedef _ResendLoaderConsumer = LoaderConsumer<UnauthenticatedSession, String?>;

extension on BuildContext {
  _ResendLoaderBloc get resendEmailLoaderBloc => loader();
}

typedef _VerificationProvider
    = FormProvider<_VerificationControllers, String, LoginResponse>;

void _handleResendState(
  BuildContext context,
  LoaderState<String?> loaderState,
) =>
    loaderState.handle(
      loaded: (error) => StyledBanner.show(
        message: error ?? 'Email resent',
        error: error != null,
      ),
      fallback: () {},
    );

void _handleConfirmState(
  BuildContext context,
  _VerificationControllers controllers,
  LoaderState<LoginResponse> loaderState,
) =>
    loaderState.handle(
      loaded: (response) {
        switch (response) {
          case LoginSuccess():
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute<void>(
                builder: (_) => const HomePage(),
              ),
              (_) => false,
            );
          case LoginFailureResponse(message: final message):
            StyledBanner.show(message: message, error: true);
            controllers.codeController.clear();
        }
      },
      fallback: () {},
    );
