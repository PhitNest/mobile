import 'dart:async';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../pages/pages.dart';
import '../../../widgets/widgets.dart';
import '../../http/http.dart';
import '../../logger.dart';
import '../session.dart';

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
  /// [initialRequest] is used to make a request immediately when the bloc is
  /// created.
  ///
  /// [initialData] is an optional parameter that can be used to set the initial
  /// state of the bloc.
  LoaderBloc.loadOnStart({
    required Future<ResType> Function(ReqType) load,
    required ReqType initialRequest,
    ResType? initialData,
    FutureOr<void> Function(LoaderState<ResType> state)? onDispose,
  }) : this(
          load: load,
          initialData: initialData,
          loadOnStart: LoadOnStart(initialRequest),
          onDispose: onDispose,
        );

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
      case LoaderLoadingState(operation: final operation):
        operation.then((response) => add(_LoaderLoadedEvent(response)));
      case LoaderLoadedState() || LoaderInitialState():
    }

    on<LoaderLoadEvent<ReqType, ResType>>(
      (event, emit) async {
        CancelableOperation<ResType> operation() =>
            CancelableOperation.fromFuture(load(event.requestData))
              ..then((response) {
                add(_LoaderLoadedEvent(response));
              });

        final state = this.state;
        switch (state) {
          case LoaderLoadingState(operation: final currentOperation):
            await currentOperation.cancel();
            switch (state) {
              case LoaderInitialLoadingState():
                emit(LoaderInitialLoadingState(operation()));
              case LoaderRefreshingState():
                emit(LoaderRefreshingState(state.data, operation()));
            }
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

    on<LoaderResetEvent<ReqType, ResType>>(
      (event, emit) async {
        switch (state) {
          case LoaderLoadingState(operation: final operation) ||
                LoaderRefreshingState(operation: final operation):
            await operation.cancel();
          case LoaderLoadedState() || LoaderInitialState():
        }
        emit(const LoaderInitialState());
      },
    );

    on<LoaderCancelEvent<ReqType, ResType>>(
      (event, emit) async {
        final state = this.state;
        switch (state) {
          case LoaderLoadingState(operation: final operation):
            await operation.cancel();
            switch (state) {
              case LoaderRefreshingState(data: final data):
                emit(LoaderLoadedState(data));
              case LoaderInitialLoadingState():
                emit(const LoaderInitialState());
            }
          case LoaderLoadedState() || LoaderInitialState():
        }
      },
    );
  }

  void set(ResType data) => add(LoaderSetEvent(data));
  void reset() => add(const LoaderResetEvent());
  void cancel() => add(const LoaderCancelEvent());

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

extension VoidReq<ResType> on LoaderBloc<void, ResType> {
  void load() => add(const LoaderLoadEvent(null));
}

extension NonVoidReq<ReqType extends Object, ResType>
    on LoaderBloc<ReqType, ResType> {
  void load(ReqType requestData) => add(LoaderLoadEvent(requestData));
}
