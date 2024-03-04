import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../../entities/entities.dart';
import '../../../repositories/repositories.dart';
import '../../../util/util.dart';

typedef ConfirmPhotoBloc = AuthLoaderBloc<void, String?>;
typedef ConfirmPhotoConsumer = AuthLoaderConsumer<void, String?>;

extension ConfirmPhotoBlocGetter on BuildContext {
  ConfirmPhotoBloc get confirmPhotoBloc => authLoader();
}

ConfirmPhotoBloc confirmPhotoBloc(BuildContext context, Uint8List photoBytes) =>
    ConfirmPhotoBloc(
      sessionLoader: context.sessionLoader,
      load: (_, session) => uploadProfilePicture(
        photo: ByteStream.fromBytes(photoBytes),
        length: photoBytes.length,
        session: session as AwsSession, // TODO: FIX
        identityId: session.credentials.userIdentityId!,
      ),
    );
