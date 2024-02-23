part of 'instructions.dart';

typedef _ChoosePhotoBloc
    = LoaderBloc<Future<ChosenPhoto?> Function(), ChosenPhoto?>;
typedef _ChoosePhotoConsumer
    = LoaderConsumer<Future<ChosenPhoto?> Function(), ChosenPhoto?>;

extension on BuildContext {
  _ChoosePhotoBloc get choosePhotoBloc => loader();
}
