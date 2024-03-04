part of 'http.dart';

sealed class HttpResponse<DataType> extends Equatable {
  final Headers headers;

  const HttpResponse(this.headers) : super();

  T handleAll<T>({
    required T Function(DataType, Headers headers) success,
    required T Function(Failure, Headers headers) failure,
  }) =>
      handle(
        success: success,
        failure: failure,
        fallback: () => throw Exception('No fallback provided'),
      );

  T handle<T>({
    T? Function(DataType, Headers headers)? success,
    T? Function(Failure, Headers headers)? failure,
    required T Function() fallback,
  }) {
    final res = this;
    switch (res) {
      case HttpResponseSuccess(data: final data, headers: final headers):
        if (success != null) {
          final res = success(data, headers);
          if (res != null) {
            return res;
          }
        }
      case HttpResponseFailure(failure: final data, headers: final headers):
        if (failure != null) {
          final res = failure(data, headers);
          if (res != null) {
            return res;
          }
        }
    }
    return fallback();
  }

  @override
  List<Object?> get props => [headers];
}

final class HttpResponseSuccess<ResType> extends HttpResponse<ResType> {
  final ResType data;

  const HttpResponseSuccess(this.data, super.headers) : super();

  @override
  List<Object?> get props => [data, headers];
}

final class HttpResponseFailure<ResType> extends HttpResponse<ResType> {
  final Failure failure;

  const HttpResponseFailure(this.failure, super.headers) : super();

  @override
  List<Object?> get props => [failure, headers];
}

extension HttpLoaderStateHandler<ResType>
    on LoaderState<HttpResponse<ResType>> {
  T handle<T>({
    T Function(ResType, Headers headers)? success,
    T Function(Failure, Headers headers)? failure,
    T Function(ResType, Headers headers)? refreshingAfterSuccess,
    T Function(Failure, Headers headers)? refreshingAfterFailure,
    T Function()? refreshing,
    T Function()? loading,
    T Function()? initialLoading,
    T Function()? initial,
    required T Function() fallback,
  }) {
    final state = this;
    switch (state) {
      case LoaderRefreshingState(data: final data):
        switch (data) {
          case HttpResponseSuccess(data: final data, headers: final headers):
            if (refreshingAfterSuccess != null) {
              return refreshingAfterSuccess(data, headers);
            } else if (success != null) {
              return success(data, headers);
            }
          case HttpResponseFailure(failure: final f, headers: final headers):
            if (refreshingAfterFailure != null) {
              return refreshingAfterFailure(f, headers);
            } else if (failure != null) {
              return failure(f, headers);
            }
        }
        if (refreshing != null) {
          return refreshing();
        } else if (loading != null) {
          return loading();
        }
      case LoaderLoadedState(data: final data):
        switch (data) {
          case HttpResponseSuccess(data: final data, headers: final headers):
            if (success != null) {
              return success(data, headers);
            }
          case HttpResponseFailure(failure: final f, headers: final headers):
            if (failure != null) {
              return failure(f, headers);
            }
        }
      case LoaderInitialLoadingState():
        if (initialLoading != null) {
          return initialLoading();
        } else if (loading != null) {
          return loading();
        }
      case LoaderInitialState():
        if (initial != null) {
          return initial();
        }
    }
    return fallback();
  }

  FutureOr<void> success(
          FutureOr<void> Function(ResType, Headers headers) success) =>
      handle(
        success: success,
        fallback: () {},
      );
}
