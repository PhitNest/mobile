part of 'http.dart';

sealed class HttpResponse<DataType> extends Equatable {
  final Headers? headers;

  const HttpResponse(this.headers) : super();

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

extension HttpAuthLoaderStateHandler<ResType>
    on LoaderState<AuthResOrLost<HttpResponse<ResType>>> {
  T handleAuthHttp<T>({
    T Function(HttpResponseSuccess<ResType>)? success,
    T Function(HttpResponseSuccess<ResType>)? refreshingAfterSuccess,
    T Function(HttpResponseFailure<ResType>)? failure,
    T Function(HttpResponseFailure<ResType>)? refreshingAfterFailure,
    T Function(AuthLost<HttpResponse<ResType>>)? authLost,
    T Function(AuthLost<HttpResponse<ResType>>)? refreshingAfterAuthLost,
    T Function()? refreshingAfterAuthRes,
    T Function()? authRes,
    T Function()? loaded,
    T Function()? refreshing,
    T Function()? initialLoading,
    T Function()? initial,
    T Function()? loading,
    required T Function() fallback,
  }) =>
      handleAuth(
        success: (res) {
          switch (res) {
            case HttpResponseSuccess():
              if (success != null) {
                final result = success(res);
                if (result != null) {
                  return result;
                }
              }
            case HttpResponseFailure():
              if (failure != null) {
                final result = failure(res);
                if (result != null) {
                  return result;
                }
              }
          }
          return authRes?.call();
        },
        authLost: authLost,
        refreshingAfterSuccess: (response) {
          switch (response) {
            case HttpResponseSuccess():
              if (refreshingAfterSuccess != null) {
                final result = refreshingAfterSuccess(response);
                if (result != null) {
                  return result;
                }
              }
            case HttpResponseFailure():
              if (refreshingAfterFailure != null) {
                final result = refreshingAfterFailure(response);
                if (result != null) {
                  return result;
                }
              }
          }
          return refreshingAfterAuthRes?.call();
        },
        refreshingAfterAuthLost: refreshingAfterAuthLost,
        refreshing: refreshing,
        loaded: loaded,
        initialLoading: initialLoading,
        initial: initial,
        loading: loading,
        fallback: fallback,
      );

  FutureOr<void> httpGoToLoginOr(
    BuildContext context, {
    FutureOr<void> Function(HttpResponseSuccess<ResType>)? success,
    FutureOr<void> Function(HttpResponseSuccess<ResType>)?
        refreshingAfterSuccess,
    FutureOr<void> Function(HttpResponseFailure<ResType>)? failure,
    FutureOr<void> Function(HttpResponseFailure<ResType>)?
        refreshingAfterFailure,
    FutureOr<void> Function(AuthLost<HttpResponse<ResType>>)? authLost,
    FutureOr<void> Function(AuthLost<HttpResponse<ResType>>)?
        refreshingAfterAuthLost,
    FutureOr<void> Function()? refreshingAfterAuthRes,
    FutureOr<void> Function()? authRes,
    FutureOr<void> Function()? loaded,
    FutureOr<void> Function()? refreshing,
    FutureOr<void> Function()? initialLoading,
    FutureOr<void> Function()? initial,
    FutureOr<void> Function()? loading,
    required FutureOr<void> Function() fallback,
  }) =>
      handleAuthHttp(
        success: success,
        authLost: (_) {
          _goToLogin(context);
          return authLost?.call(_);
        },
        refreshingAfterSuccess: refreshingAfterSuccess,
        refreshingAfterAuthLost: (_) {
          _goToLogin(context);
          return refreshingAfterAuthLost?.call(_);
        },
        loaded: loaded,
        refreshing: refreshing,
        initialLoading: initialLoading,
        initial: initial,
        loading: loading,
        fallback: fallback,
      );
}
