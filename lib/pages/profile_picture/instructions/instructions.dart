import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme.dart';
import '../../../util/util.dart';
import '../../../widgets/widgets.dart';
import '../chosen_photo.dart';
import 'bloc.dart';

final class PhotoInstructionsWidget extends StatelessWidget {
  static final imagePicker = ImagePicker();

  const PhotoInstructionsWidget({super.key}) : super();

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          Text(
            'First, let\'s put a face to your name.',
            style: theme.textTheme.bodyLarge,
          ),
          Text(
            'Add a photo of yourself\n**from the SHOULDERS UP**\n'
            '\nJust enough for gym buddies to recognize you! Like'
            ' this...',
            style: theme.textTheme.bodyMedium,
          ),
          Image.asset(
            'assets/images/selfie.png',
            width: 200,
          ),
          ElevatedButton(
            onPressed: () => context.choosePhotoBloc.load(
              () => choosePhoto(
                context,
                () => imagePicker.pickImage(
                  source: ImageSource.camera,
                  preferredCameraDevice: CameraDevice.front,
                ),
              ),
            ),
            child: Text(
              'TAKE PHOTO',
              style: theme.textTheme.bodySmall,
            ),
          ),
          StyledOutlineButton(
            onPress: () => context.choosePhotoBloc.load(
              () => choosePhoto(
                context,
                () => imagePicker.pickImage(
                  source: ImageSource.gallery,
                ),
              ),
            ),
            text: 'UPLOAD PHOTO',
          ),
        ],
      );
}
