part of 'login.dart';

final class LoginControllers extends FormControllers {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}

extension on BuildContext {
  LoaderBloc<LoginParams, LoginResponse> get loginBloc => loader();
}

typedef LoginProvider
    = FormProvider<LoginControllers, LoginParams, LoginResponse>;

void _handleStateChanged(BuildContext context, LoginControllers controllers,
    LoaderState<LoginResponse> loaderState) {
  switch (loaderState) {
    case LoaderLoadedState(data: final response):
      switch (response) {
        case LoginSuccess():
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (_) => const HomePage(),
            ),
            (_) => false,
          );
        case LoginConfirmationRequired(session: final session):
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => VerificationPage(
                unauthenticatedSession: session,
                resend: (session) =>
                    Cognito.instance.resendConfirmationEmail(session),
                confirm: (session, code) => Cognito.instance.confirmEmail(
                  session: session,
                  code: code,
                ),
                loginParams: _params(controllers),
              ),
            ),
          );
        case LoginFailureResponse(message: final message) ||
              LoginUnknownResponse(message: final message) ||
              LoginChangePasswordRequired(message: final message):
          StyledBanner.show(
            message: message,
            error: true,
          );
      }
    default:
  }
}
