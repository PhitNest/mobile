part of 'confirm.dart';

sealed class _ConfirmPhotoResponse extends Equatable {
  const _ConfirmPhotoResponse() : super();
}

final class _ConfirmPhotoSuccess extends _ConfirmPhotoResponse {
  const _ConfirmPhotoSuccess() : super();

  @override
  List<Object?> get props => [];
}

final class _ConfirmPhotoFailure extends _ConfirmPhotoResponse {
  final String message;

  const _ConfirmPhotoFailure({
    required this.message,
  }) : super();

  @override
  List<Object?> get props => [message];
}
