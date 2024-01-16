part of 'parallel_loader.dart';

/// An async operation that can be pushed onto the parallel loader stack. This
/// class is used internally by the parallel loader bloc. It is a node in a
/// linked list.
final class ParallelOperation<ReqType, ResType>
    with LinkedListEntry<ParallelOperation<ReqType, ResType>>, EquatableMixin {
  final CancelableOperation<ResType> operation;
  final ReqType req;

  ParallelOperation(this.operation, this.req) : super();

  @override
  List<Object?> get props => [operation, req];
}

/// Base class for all parallel loader states.
sealed class ParallelLoaderBaseState<ReqType, ResType> extends Equatable {
  final LinkedList<ParallelOperation<ReqType, ResType>> operations;

  const ParallelLoaderBaseState(this.operations) : super();

  @override
  List<Object?> get props => [operations];
}

final class ParallelLoaderState<ReqType, ResType>
    extends ParallelLoaderBaseState<ReqType, ResType> {
  const ParallelLoaderState(super.operations) : super();
}

/// State that indicates the parallel loader has loaded some data.
final class ParallelLoadedState<ReqType, ResType>
    extends ParallelLoaderState<ReqType, ResType> {
  final ResType data;
  final ReqType req;

  const ParallelLoadedState(super.operations, this.data, this.req) : super();

  @override
  List<Object?> get props => [...super.props, data, req];
}
