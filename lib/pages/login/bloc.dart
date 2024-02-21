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

void _handleState(
  BuildContext context,
  LoginControllers controllers,
  LoaderState<LoginResponse> loaderState,
) =>
    loaderState.handle(
      loaded: (response) => switch (response) {
        LoginSuccess() => Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (_) => const HomePage(),
            ),
            (_) => false,
          ),
        LoginConfirmationRequired(session: final session) =>
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => VerificationPage(
                session: session,
                resend: (session) => resendConfirmationEmail(session),
                confirm: (session, code) => confirmEmail(
                  session: session,
                  code: code,
                ),
                loginParams: _params(controllers),
              ),
            ),
          ),
        LoginFailureResponse(message: final message) ||
        LoginUnknownResponse(message: final message) ||
        LoginChangePasswordRequired(message: final message) =>
          StyledBanner.show(
            message: message,
            error: true,
          ),
      },
      fallback: () {},
    );
