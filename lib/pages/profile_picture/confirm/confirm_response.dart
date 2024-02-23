part of 'confirm.dart';

sealed class ConfirmPhotoResponse extends Equatable {
  const ConfirmPhotoResponse() : super();
}

final class ConfirmPhotoSuccess extends ConfirmPhotoResponse {
  const ConfirmPhotoSuccess() : super();

  @override
  List<Object?> get props => [];
}

final class ConfirmPhotoFailure extends ConfirmPhotoResponse {
  final String message;

  const ConfirmPhotoFailure({
    required this.message,
  }) : super();

  @override
  List<Object?> get props => [message];
}
