import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../util/util.dart';
import '../../../widgets/widgets.dart';
import '../chosen_photo.dart';
import 'bloc.dart';
import 'confirm_photo.dart';

final class ConfirmPhotoProviderWidget extends StatelessWidget {
  final ChosenPhoto photo;

  late final Image pfp =
      kIsWeb ? Image.memory(photo.bytes) : Image.file(File(photo.file.path));

  ConfirmPhotoProviderWidget({
    super.key,
    required this.photo,
  }) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => confirmPhotoBloc(context, photo.bytes),
        child: ConfirmPhotoConsumer(
          listener: (context, confirmState) => confirmState.handleAuthLost(
            context,
            success: (response) {
              if (response != null) {
                StyledBanner.show(message: response, error: true);
              } else {
                Navigator.of(context)
                  ..pop()
                  ..pop(pfp);
              }
            },
            fallback: () {},
          ),
          builder: (context, confirmState) =>
              ConfirmPhotoWidget(pfp: pfp, loading: confirmState.isLoading),
        ),
      );
}
