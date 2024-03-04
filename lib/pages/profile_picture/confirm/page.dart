import 'package:flutter/material.dart';

import '../chosen_photo.dart';
import 'provider.dart';

final class ConfirmPhotoPage extends StatelessWidget {
  final ChosenPhoto photo;

  const ConfirmPhotoPage({
    super.key,
    required this.photo,
  }) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConfirmPhotoProviderWidget(photo: photo),
        ),
      );
}
