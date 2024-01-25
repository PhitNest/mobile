import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../theme.dart';
import '../../../util/aws/aws.dart';
import '../../../util/bloc/bloc.dart';
import '../../../widgets/widgets.dart';
import '../../login/login.dart';

part 'bloc.dart';

final class ConfirmPhotoPage extends StatelessWidget {
  final CroppedFile photo;
  late final pfp = Image.file(File(photo.path));

  ConfirmPhotoPage({
    super.key,
    required this.photo,
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
                  final bytes = await photo.readAsBytes();
                  final error = await uploadProfilePicture(
                    photo: ByteStream.fromBytes(bytes),
                    length: bytes.length,
                    session: session,
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
