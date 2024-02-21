part of 'instructions.dart';

final class _ChosenPhoto extends Equatable {
  final CroppedFile file;
  final Uint8List bytes;

  const _ChosenPhoto({
    required this.file,
    required this.bytes,
  }) : super();

  @override
  List<Object?> get props => [file, bytes];
}

Future<_ChosenPhoto?> _photoChosen(
  BuildContext context,
  Future<XFile?> Function() getImage,
) async {
  try {
    final webUiSettings = WebUiSettings(
      context: context,
      presentStyle: CropperPresentStyle.dialog,
      enableZoom: true,
    );
    final image = await getImage();

    if (image != null) {
      final cropped = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(
            ratioX: kProfilePictureAspectRatio.width,
            ratioY: kProfilePictureAspectRatio.height,
          ),
          uiSettings: [webUiSettings]);
      if (cropped != null) {
        return _ChosenPhoto(
          file: cropped,
          bytes: await cropped.readAsBytes(),
        );
      }
    }
    return null;
  } catch (e) {
    StyledBanner.show(message: e.toString(), error: true);
    await logError(e.toString());
    return null;
  }
}
