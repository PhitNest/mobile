import 'package:flutter/material.dart';

import 'provider.dart';

final class PhotoInstructionsPage extends StatelessWidget {
  const PhotoInstructionsPage({super.key}) : super();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: PhotoInstructionsProviderWidget(),
        ),
      );
}
