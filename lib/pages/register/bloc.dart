part of 'register.dart';

final class _RegisterControllers extends FormControllers {
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

extension on BuildContext {
  FormBloc<_RegisterControllers> get registerFormBloc => BlocProvider.of(this);
}

typedef _RegisterProvider
    = FormProvider<_RegisterControllers, RegisterParams, RegisterResponse>;

void _handleState(
  BuildContext context,
  _RegisterControllers controllers,
  LoaderState<RegisterResponse> loaderState,
) =>
    loaderState.handle(
      loaded: (response) => switch (response) {
        RegisterSuccess(session: final session) => Navigator.pushReplacement(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => VerificationPage(
                loginParams: LoginParams(
                  email: controllers.emailController.text,
                  password: controllers.passwordController.text,
                ),
                resend: (session) => resendConfirmationEmail(session),
                confirm: (session, code) =>
                    confirmEmail(session: session, code: code),
                session: session,
              ),
            ),
          ),
        RegisterFailureResponse(message: final message) =>
          StyledBanner.show(message: message, error: true),
      },
      fallback: () {},
    );
