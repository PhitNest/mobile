import 'dart:async';

import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logger.dart';

part 'event.dart';
part 'state.dart';

/// Wraps a [T] in an object so that it can be passed to a [LoaderBloc] as an
/// optional parameter. This is needed because T may be of type void, and
/// therefore it is impossible to distinguish whether the constructor parameter
/// `loadOnStart` of [LoaderBloc] was passed or not.
final class LoadOnStart<T> extends Equatable {
  final T req;

  const LoadOnStart(this.req) : super();

  @override
  List<Object?> get props => [req];
}

/// Loads data from an async source and emits the result as a [LoaderState].
///
/// [ReqType] is the type of the request data. This can be `void` if no request
/// data is needed.
///
/// [ResType] is the type of the response data.
base class LoaderBloc<ReqType, ResType>
    extends Bloc<LoaderEvent<ReqType, ResType>, LoaderState<ResType>> {
  final FutureOr<void> Function(LoaderState<ResType> state)? onDispose;

  /// [load] is the function that is used to load data from an async source.
  ///
  /// [loadOnStart] is an optional parameter that can be used to load data
  /// immediately after the bloc is created.
  ///
  /// [initialData] is an optional parameter that can be used to set the initial
  /// state of the bloc.
  LoaderBloc({
    required Future<ResType> Function(ReqType) load,
    ResType? initialData,
    LoadOnStart<ReqType>? loadOnStart,
    this.onDispose,
  }) : super((() {
          if (loadOnStart != null) {
            final operation =
                CancelableOperation.fromFuture(load(loadOnStart.req));
            operation.then((p0) => null);
            return initialData != null
                ? LoaderRefreshingState(initialData, operation)
                : LoaderInitialLoadingState(operation);
          }

          return initialData != null
              ? LoaderLoadedState(initialData)
              : LoaderInitialState<ResType>();
        })()) {
    // If the initial state is a loading state, upon completion of the
    // operation, the bloc should emit a loaded state.
    switch (state) {
      case LoaderLoadingState(operation: final operation) ||
            LoaderRefreshingState(operation: final operation):
        operation.then((response) => add(_LoaderLoadedEvent(response)));
      case LoaderLoadedState() || LoaderInitialState():
    }

    on<LoaderLoadEvent<ReqType, ResType>>(
      (event, emit) {
        CancelableOperation<ResType> operation() =>
            CancelableOperation.fromFuture(load(event.requestData))
              ..then((response) => add(_LoaderLoadedEvent(response)));

        switch (state) {
          case LoaderLoadingState():
            badState(state, event);
          case LoaderInitialState():
            emit(LoaderInitialLoadingState(operation()));
          case LoaderLoadedState(data: final data):
            emit(LoaderRefreshingState(data, operation()));
        }
      },
    );

    on<_LoaderLoadedEvent<ReqType, ResType>>(
      (event, emit) {
        switch (state) {
          case LoaderLoadingState():
            emit(LoaderLoadedState(event.data));
          case LoaderLoadedState() || LoaderInitialState():
            badState(state, event);
        }
      },
    );

    on<LoaderSetEvent<ReqType, ResType>>(
      (event, emit) async {
        switch (state) {
          case LoaderLoadingState(operation: final operation) ||
                LoaderRefreshingState(operation: final operation):
            await operation.cancel();
          case LoaderLoadedState() || LoaderInitialState():
        }
        emit(LoaderLoadedState(event.data));
      },
    );

    on<LoaderCancelEvent<ReqType, ResType>>(
      (event, emit) async {
        switch (state) {
          case LoaderRefreshingState(
              operation: final operation,
              data: final data
            ):
            await operation.cancel();
            emit(LoaderLoadedState(data));
          case LoaderLoadingState(operation: final operation):
            await operation.cancel();
            emit(const LoaderInitialState());
          case LoaderLoadedState() || LoaderInitialState():
        }
      },
    );
  }

  @override
  Future<void> close() async {
    switch (state) {
      case LoaderLoadingState(operation: final operation):
        await operation.cancel();
      case LoaderLoadedState() || LoaderInitialState():
    }
    onDispose?.call(state);
    return super.close();
  }
}

typedef LoaderConsumer<ReqType, ResType>
    = BlocConsumer<LoaderBloc<ReqType, ResType>, LoaderState<ResType>>;

extension LoaderGetter on BuildContext {
  LoaderBloc<ReqType, ResType> loader<ReqType, ResType>() =>
      BlocProvider.of(this);
}
