import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../entities/entities.dart';
import '../../../repositories/s3/aws.dart';
import '../../../theme.dart';
import '../../../util/bloc/bloc.dart';
import '../../../widgets/widgets.dart';
import '../../login/login.dart';

part 'bloc.dart';

final class ConfirmPhotoPage extends StatelessWidget {
  final CroppedFile photo;
  final Uint8List photoBytes;
  late final Image pfp =
      kIsWeb ? Image.memory(photoBytes) : Image.file(File(photo.path));

  // ignore: prefer_const_constructors_in_immutables
  ConfirmPhotoPage({
    super.key,
    required this.photo,
    required this.photoBytes,
  }) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: BlocProvider(
              create: (context) => ConfirmPhotoBloc(
                sessionLoader: context.sessionLoader,
                load: (_, session) async {
                  final error = await uploadProfilePicture(
                    photo: ByteStream.fromBytes(photoBytes),
                    length: photoBytes.length,
                    session: session as AwsSession, // TODO: FIX
                    identityId: session.credentials.userIdentityId!,
                  );
                  if (error != null) {
                    return ConfirmPhotoFailure(message: error);
                  } else {
                    return const ConfirmPhotoSuccess();
                  }
                },
              ),
              child: ConfirmPhotoConsumer(
                listener: (context, confirmState) =>
                    _handleStateChanged(context, confirmState, pfp),
                builder: (context, confirmState) => Column(
                  children: [
                    pfp,
                    ...switch (confirmState) {
                      LoaderLoadingState() => const [Loader()],
                      _ => [
                          ElevatedButton(
                            child: Text(
                              'CONFIRM',
                              style: theme.textTheme.bodySmall,
                            ),
                            onPressed: () => context.confirmPhotoBloc
                                .add(const LoaderLoadEvent(null)),
                          ),
                          StyledOutlineButton(
                              text: 'BACK',
                              onPress: () => Navigator.of(context).pop()),
                        ]
                    },
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
