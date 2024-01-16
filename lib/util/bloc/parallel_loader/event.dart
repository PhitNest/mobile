part of 'parallel_loader.dart';

/// Base class for all parallel loader events.
sealed class ParallelLoaderEvent<ReqType, ResType> extends Equatable {
  const ParallelLoaderEvent() : super();
}

/// Use this event to start a load/reload action.
final class ParallelPushEvent<ReqType, ResType>
    extends ParallelLoaderEvent<ReqType, ResType> {
  final ReqType requestData;

  const ParallelPushEvent(this.requestData) : super();

  @override
  List<Object?> get props => [requestData];
}

/// Use this event to cancel a load/reload action.
final class ParallelPopEvent<ReqType, ResType>
    extends ParallelLoaderEvent<ReqType, ResType> {
  final ParallelOperation<ReqType, ResType> operation;
  final ResType res;

  const ParallelPopEvent(this.operation, this.res) : super();

  @override
  List<Object?> get props => [operation, res];
}

/// Use this event to cancel all load/reload actions.
final class ParallelClearEvent<ReqType, ResType>
    extends ParallelLoaderEvent<ReqType, ResType> {
  const ParallelClearEvent() : super();

  @override
  List<Object?> get props => [];
}
