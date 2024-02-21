import 'dart:io';

import 'package:equatable/equatable.dart';
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

part 'bloc.dart';
part 'confirm_response.dart';

final class ConfirmPhotoPage extends StatelessWidget {
  final CroppedFile photo;
  final Uint8List photoBytes;

  late final Image pfp =
      kIsWeb ? Image.memory(photoBytes) : Image.file(File(photo.path));

  ConfirmPhotoPage({
    super.key,
    required this.photo,
    required this.photoBytes,
  }) : super();

  Future<_ConfirmPhotoResponse> _submitPhoto(Session session) async {
    final error = await uploadProfilePicture(
      photo: ByteStream.fromBytes(photoBytes),
      length: photoBytes.length,
      session: session as AwsSession, // TODO: FIX
      identityId: session.credentials.userIdentityId!,
    );
    if (error != null) {
      return _ConfirmPhotoFailure(message: error);
    } else {
      return const _ConfirmPhotoSuccess();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: BlocProvider(
            create: (context) => _ConfirmPhotoBloc(
              sessionLoader: context.sessionLoader,
              load: (_, session) => _submitPhoto(session),
            ),
            child: _ConfirmPhotoConsumer(
              listener: (context, confirmState) =>
                  _handleState(context, confirmState, pfp),
              builder: (context, confirmState) => ListView(
                children: [
                  pfp,
                  ...confirmState.loaderOrList(
                    [
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
                        onPress: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
