part of 'forgot_password.dart';

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

void _handleStateChanged(
  BuildContext context,
  ForgotPasswordControllers controllers,
  LoaderState<SendForgotPasswordResponse> loaderState,
) {
  switch (loaderState) {
    case LoaderLoadedState(data: final response):
      switch (response) {
        case SendForgotPasswordSuccess(user: final user):
          Navigator.push(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => VerificationPage(
                loginParams: LoginParams(
                  email: controllers.emailController.text,
                  password: controllers.newPasswordController.text,
                ),
                unauthenticatedSession: UnauthenticatedSession(user: user),
                resend: (session) => Cognito.instance
                    .sendForgotPasswordRequest(
                      controllers.emailController.text,
                    )
                    .then(
                      (state) => switch (state) {
                        SendForgotPasswordSuccess() => null,
                        SendForgotPasswordFailureResponse(
                          message: final message
                        ) =>
                          message,
                      },
                    ),
                confirm: (session, code) => Cognito.instance
                    .submitForgotPassword(
                      params: SubmitForgotPasswordParams(
                        email: controllers.emailController.text,
                        code: code,
                        newPassword: controllers.newPasswordController.text,
                      ),
                      session: session,
                    )
                    .then((state) => state?.message),
              ),
            ),
          );
        case SendForgotPasswordFailureResponse(message: final message):
          StyledBanner.show(
            message: message,
            error: true,
          );
      }
    default:
  }
}
