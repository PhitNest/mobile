part of 'confirm.dart';

typedef _ConfirmPhotoBloc = AuthLoaderBloc<void, ConfirmPhotoResponse>;
typedef _ConfirmPhotoConsumer = AuthLoaderConsumer<void, ConfirmPhotoResponse>;

extension on BuildContext {
  _ConfirmPhotoBloc get confirmPhotoBloc => authLoader();
}
