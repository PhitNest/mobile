import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../confirm/page.dart';
import 'bloc.dart';
import 'instructions.dart';

final class PhotoInstructionsProviderWidget extends StatelessWidget {
  const PhotoInstructionsProviderWidget({super.key}) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: choosePhotoBloc,
        child: ChoosePhotoConsumer(
          listener: (context, choosePhotoState) =>
              choosePhotoState.loaded((photo) {
            if (photo != null) {
              Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  builder: (_) => ConfirmPhotoPage(photo: photo),
                ),
              );
            }
          }),
          builder: (context, choosePhotoState) =>
              const PhotoInstructionsWidget(),
        ),
      );
}
