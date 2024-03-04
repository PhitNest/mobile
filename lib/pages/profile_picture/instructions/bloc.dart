import 'package:flutter/material.dart';

import '../../../util/util.dart';
import '../chosen_photo.dart';

typedef ChoosePhotoBloc
    = LoaderBloc<Future<ChosenPhoto?> Function(), ChosenPhoto?>;
typedef ChoosePhotoConsumer
    = LoaderConsumer<Future<ChosenPhoto?> Function(), ChosenPhoto?>;

extension ChoosePhotoBlocGetter on BuildContext {
  ChoosePhotoBloc get choosePhotoBloc => loader();
}

ChoosePhotoBloc choosePhotoBloc(BuildContext context) =>
    ChoosePhotoBloc(load: (choosePhoto) => choosePhoto());
