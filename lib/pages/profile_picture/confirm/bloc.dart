part of 'confirm.dart';

typedef _ConfirmPhotoBloc = AuthLoaderBloc<void, _ConfirmPhotoResponse>;
typedef _ConfirmPhotoConsumer = AuthLoaderConsumer<void, _ConfirmPhotoResponse>;

extension on BuildContext {
  _ConfirmPhotoBloc get confirmPhotoBloc => authLoader();
}

void _handleState(
  BuildContext context,
  LoaderState<AuthResOrLost<_ConfirmPhotoResponse>> loaderState,
  Image profilePicture,
) =>
    loaderState.goToLoginOr(
      context,
      success: (response) => switch (response) {
        _ConfirmPhotoSuccess() => Navigator.of(context)
          ..pop()
          ..pop(profilePicture),
        _ConfirmPhotoFailure(message: final error) =>
          StyledBanner.show(message: error, error: true),
      },
      fallback: () {},
    );
