part of 'http.dart';

sealed class HttpResponse<DataType> extends Equatable {
  final Headers? headers;

  const HttpResponse(this.headers) : super();

  T handle<T>({
    T? Function(DataType, Headers? headers)? success,
    T? Function(DataType, Headers? headers)? cache,
    T? Function(DataType, Headers? headers)? ok,
    T? Function(Failure, Headers? headers)? failure,
    required T Function() fallback,
  }) {
    final res = this;
    switch (res) {
      case HttpResponseSuccess(data: final data, headers: final headers):
        switch (res) {
          case HttpResponseOk(data: final data, headers: final headers):
            if (ok != null) {
              final res = ok(data, headers);
              if (res != null) {
                return res;
              }
            }
          case HttpResponseCache(data: final data):
            if (cache != null) {
              final res = cache(data, headers);
              if (res != null) {
                return res;
              }
            }
        }
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

sealed class HttpResponseSuccess<ResType> extends HttpResponse<ResType> {
  final ResType data;

  const HttpResponseSuccess(this.data, super.headers) : super();

  @override
  List<Object?> get props => [data, headers];
}

final class HttpResponseOk<ResType> extends HttpResponseSuccess<ResType> {
  const HttpResponseOk(super.data, super.headers) : super();
}

final class HttpResponseCache<ResType> extends HttpResponseSuccess<ResType> {
  const HttpResponseCache(ResType data) : super(data, null);
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
    T Function(HttpResponseSuccess<ResType>)? success,
    T Function(HttpResponseFailure<ResType>)? failure,
    T Function(HttpResponseSuccess<ResType>)? refreshingAfterSuccess,
    T Function(HttpResponseFailure<ResType>)? refreshingAfterFailure,
    T Function()? loading,
    T Function()? initialLoading,
    T Function()? initial,
    required T Function() fallback,
  }) {
    final state = this;
    switch (state) {
      case LoaderRefreshingState(data: final data):
        switch (data) {
          case HttpResponseSuccess():
            if (refreshingAfterSuccess != null) {
              return refreshingAfterSuccess(data);
            } else if (success != null) {
              return success(data);
            } else if (loading != null) {
              return loading();
            }
          case HttpResponseFailure():
            if (refreshingAfterFailure != null) {
              return refreshingAfterFailure(data);
            } else if (failure != null) {
              return failure(data);
            } else if (loading != null) {
              return loading();
            }
        }
      case LoaderLoadedState(data: final data):
        switch (data) {
          case HttpResponseSuccess():
            if (success != null) {
              return success(data);
            }
          case HttpResponseFailure():
            if (failure != null) {
              return failure(data);
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
}
