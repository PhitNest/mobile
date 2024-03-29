import 'dart:collection';

import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event.dart';
part 'state.dart';

/// Can be used to make multiple parallel requests to an async source and emit
/// the result as a [ParallelLoaderState].
base class ParallelLoaderBloc<ReqType, ResType> extends Bloc<
    ParallelLoaderEvent<ReqType, ResType>,
    ParallelLoaderState<ReqType, ResType>> {
  ParallelLoaderBloc({required Future<ResType> Function(ReqType) load})
      : super(ParallelLoaderState(LinkedList())) {
    on<ParallelPushEvent<ReqType, ResType>>((event, emit) {
      final ParallelOperation<ReqType, ResType> operation = ParallelOperation(
          CancelableOperation.fromFuture(load(event.requestData)),
          event.requestData);
      operation.operation.then((res) => add(ParallelPopEvent(operation, res)));
      emit(ParallelLoaderState(state.operations..add(operation)));
    });

    on<ParallelPopEvent<ReqType, ResType>>((event, emit) {
      event.operation.unlink();
      emit(ParallelLoadedState(
          state.operations, event.res, event.operation.req));
    });

    on<ParallelClearEvent<ReqType, ResType>>(
      (event, emit) async {
        for (final operation in state.operations) {
          await operation.operation.cancel();
        }
        emit(ParallelLoaderState(LinkedList()));
      },
    );
  }

  void push(ReqType req) => add(ParallelPushEvent(req));
  void clear() => add(const ParallelClearEvent());
  void pop(ParallelOperation<ReqType, ResType> operation, ResType res) =>
      add(ParallelPopEvent(operation, res));

  @override
  Future<void> close() async {
    for (final operation in state.operations) {
      await operation.operation.cancel();
    }
    return super.close();
  }
}

typedef ParallelLoaderConsumer<ReqType, ResType> = BlocConsumer<
    ParallelLoaderBloc<ReqType, ResType>,
    ParallelLoaderState<ReqType, ResType>>;

extension ParallelLoaderGetter on BuildContext {
  ParallelLoaderBloc<ReqType, ResType> parallelBloc<ReqType, ResType>() =>
      BlocProvider.of(this);
}
