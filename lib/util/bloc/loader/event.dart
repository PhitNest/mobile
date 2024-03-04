part of 'loader.dart';

/// Base class for all loader events.
sealed class LoaderEvent<ReqType, ResType> extends Equatable {
  const LoaderEvent() : super();
}

/// Use this event to load/reload data from an async source.
final class LoaderLoadEvent<ReqType, ResType>
    extends LoaderEvent<ReqType, ResType> {
  final ReqType requestData;

  const LoaderLoadEvent(this.requestData) : super();

  @override
  List<Object?> get props => [requestData];
}

/// Event that indicates the data has been loaded.
final class _LoaderLoadedEvent<ReqType, ResType>
    extends LoaderEvent<ReqType, ResType> {
  final ResType data;

  const _LoaderLoadedEvent(this.data) : super();

  @override
  List<Object?> get props => [data];
}

/// Use this event to set the state of the loader to a specific value manually.
final class LoaderSetEvent<ReqType, ResType>
    extends LoaderEvent<ReqType, ResType> {
  final ResType data;

  const LoaderSetEvent(this.data) : super();

  @override
  List<Object?> get props => [data];
}

/// Use this event to reset the loader to its initial state.
final class LoaderResetEvent<ReqType, ResType>
    extends LoaderEvent<ReqType, ResType> {
  const LoaderResetEvent() : super();

  @override
  List<Object?> get props => [];
}

/// Use this event to cancel the current loading operation.
final class LoaderCancelEvent<ReqType, ResType>
    extends LoaderEvent<ReqType, ResType> {
  const LoaderCancelEvent() : super();

  @override
  List<Object?> get props => [];
}
