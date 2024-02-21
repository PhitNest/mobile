import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/constants.dart';
import '../../../theme.dart';
import '../../../util/bloc/bloc.dart';
import '../../../util/logger.dart';
import '../../../widgets/widgets.dart';
import '../confirm/confirm.dart';

part 'bloc.dart';
part 'chosen_photo.dart';

final class PhotoInstructionsPage extends StatelessWidget {
  static final _imagePicker = ImagePicker();

  const PhotoInstructionsPage({super.key}) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: BlocProvider(
            create: (_) =>
                _ChoosePhotoBloc(load: (photoChooser) => photoChooser()),
            child: _ChoosePhotoConsumer(
              listener: _handleState,
              builder: (context, choosePhotoState) => ListView(
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
                    onPressed: () => context.choosePhotoBloc.add(
                      LoaderLoadEvent(
                        () => _photoChosen(
                          context,
                          () => _imagePicker.pickImage(
                            source: ImageSource.camera,
                            preferredCameraDevice: CameraDevice.front,
                          ),
                        ),
                      ),
                    ),
                    child: Text(
                      'TAKE PHOTO',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  StyledOutlineButton(
                    onPress: () => context.choosePhotoBloc.add(
                      LoaderLoadEvent(
                        () => _photoChosen(
                          context,
                          () => _imagePicker.pickImage(
                            source: ImageSource.gallery,
                          ),
                        ),
                      ),
                    ),
                    text: 'UPLOAD PHOTO',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
