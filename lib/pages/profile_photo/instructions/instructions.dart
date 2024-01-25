import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

final class PhotoInstructionsPage extends StatelessWidget {
  const PhotoInstructionsPage({super.key}) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) =>
                        ChoosePhotoBloc(load: (photoChooser) => photoChooser()),
                  ),
                ],
                child: ChoosePhotoConsumer(
                  listener: (context, choosePhotoState) => _handleStateChanged(
                    context,
                    choosePhotoState,
                  ),
                  builder: (context, choosePhotoState) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'First, let\'s put a face to your name.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        'Add a photo of yourself\n**from the SHOULDERS UP**\n\n'
                        'Just enough for gym buddies to recognize you! Like '
                        'this...',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Center(
                        child: Image.asset(
                          'assets/images/selfie.png',
                          width: 200,
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => context.choosePhotoBloc
                              .add(LoaderLoadEvent(() => _photoChosen(
                                    context,
                                    () => ImagePicker().pickImage(
                                      source: ImageSource.camera,
                                      preferredCameraDevice: CameraDevice.front,
                                    ),
                                  ))),
                          child: Text(
                            'TAKE PHOTO',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                      Center(
                        child: StyledOutlineButton(
                          onPress: () => context.choosePhotoBloc
                              .add(LoaderLoadEvent(() => _photoChosen(
                                    context,
                                    () => ImagePicker()
                                        .pickImage(source: ImageSource.gallery),
                                  ))),
                          text: 'UPLOAD PHOTO',
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
