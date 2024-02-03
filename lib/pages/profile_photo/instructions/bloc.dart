part of 'instructions.dart';

typedef ChoosePhotoBloc
    = LoaderBloc<Future<CroppedFile?> Function(), CroppedFile?>;
typedef ChoosePhotoConsumer
    = LoaderConsumer<Future<CroppedFile?> Function(), CroppedFile?>;

extension on BuildContext {
  ChoosePhotoBloc get choosePhotoBloc => loader();
}

Future<CroppedFile?> _photoChosen(
  BuildContext context,
  Future<XFile?> Function() getImage,
) =>
    getImage().then(
      (image) async {
        if (image != null) {
          return await ImageCropper().cropImage(
              sourcePath: image.path,
              aspectRatio: CropAspectRatio(
                ratioX: kProfilePictureAspectRatio.width,
                ratioY: kProfilePictureAspectRatio.height,
              ),
              uiSettings: [
                WebUiSettings(
                    context: context, presentStyle: CropperPresentStyle.page)
              ]);
        }
        return null;
      },
    ).catchError(
      (dynamic e) async {
        StyledBanner.show(message: e.toString(), error: true);
        await logError(e.toString());
        return null;
      },
    );

void _handleStateChanged(
  BuildContext context,
  LoaderState<CroppedFile?> loaderState,
) {
  switch (loaderState) {
    case LoaderLoadedState(data: final photo):
      if (photo != null) {
        Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (_) => ConfirmPhotoPage(photo: photo),
          ),
        );
      }
    default:
  }
}
