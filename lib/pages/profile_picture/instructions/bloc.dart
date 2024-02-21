part of 'instructions.dart';

typedef _ChoosePhotoBloc
    = LoaderBloc<Future<_ChosenPhoto?> Function(), _ChosenPhoto?>;
typedef _ChoosePhotoConsumer
    = LoaderConsumer<Future<_ChosenPhoto?> Function(), _ChosenPhoto?>;

extension on BuildContext {
  _ChoosePhotoBloc get choosePhotoBloc => loader();
}

void _handleState(
  BuildContext context,
  LoaderState<_ChosenPhoto?> loaderState,
) =>
    loaderState.handle(
      loaded: (photo) {
        if (photo != null) {
          Navigator.of(context).push(
            CupertinoPageRoute<void>(
              builder: (_) => ConfirmPhotoPage(
                photo: photo.file,
                photoBytes: photo.bytes,
              ),
            ),
          );
        }
      },
      fallback: () {},
    );
