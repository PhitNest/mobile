import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/constants.dart';
import '../../../util/logger.dart';
import '../../../widgets/widgets.dart';

final class ChosenPhoto extends Equatable {
  final CroppedFile file;
  final Uint8List bytes;

  const ChosenPhoto({
    required this.file,
    required this.bytes,
  }) : super();

  @override
  List<Object?> get props => [file, bytes];
}

Future<ChosenPhoto?> choosePhoto(
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
        return ChosenPhoto(
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
