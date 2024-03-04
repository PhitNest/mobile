part of 'loader.dart';

/// Base class for all loader states.
sealed class LoaderState<ResType> extends Equatable {
  const LoaderState() : super();

  bool get isLoading => false;

  T handleAll<T>({
    required T Function(ResType)? loaded,
    required T Function(ResType)? refreshing,
    required T Function()? initialLoading,
    required T Function()? initial,
  }) =>
      handle(
        loaded: loaded,
        refreshing: refreshing,
        initialLoading: initialLoading,
        initial: initial,
        loading: () => throw Exception('No loading provided'),
        fallback: () => throw Exception('No fallback provided'),
      );

  T handleLoading<T>({
    required T Function(ResType) loaded,
    required T Function() loading,
    required T Function() initial,
  }) =>
      handle(
        initial: initial,
        loaded: loaded,
        loading: loading,
        fallback: () => throw Exception('No fallback provided'),
      );

  T handle<T>({
    T? Function(ResType)? loaded,
    T? Function(ResType)? refreshing,
    T? Function()? loading,
    T? Function()? initialLoading,
    T? Function()? initial,
    required T Function() fallback,
  }) {
    final state = this;
    switch (state) {
      case LoaderLoadingState():
        switch (state) {
          case LoaderInitialLoadingState():
            if (initialLoading != null) {
              final res = initialLoading();
              if (res != null) {
                return res;
              }
            }
          case LoaderRefreshingState(data: final data):
            if (refreshing != null) {
              final res = refreshing(data);
              if (res != null) {
                return res;
              }
            }
        }
        if (loading != null) {
          final res = loading();
          if (res != null) {
            return res;
          }
        }
      case LoaderInitialState():
        if (initial != null) {
          final res = initial();
          if (res != null) {
            return res;
          }
        }
      case LoaderLoadedState(data: final data):
        if (loaded != null) {
          final res = loaded(data);
          if (res != null) {
            return res;
          }
        }
    }
    return fallback();
  }

  FutureOr<void> loaded(FutureOr<void> Function(ResType) loaded) => handle(
        loaded: loaded,
        fallback: () {},
      );
}

/// Initial state of the loader. No data is loaded.
final class LoaderInitialState<ResType> extends LoaderState<ResType> {
  const LoaderInitialState() : super();

  @override
  List<Object?> get props => [];
}

/// Base class for states that indicates the loader is loading data.
sealed class LoaderLoadingState<ResType> extends LoaderState<ResType> {
  final CancelableOperation<ResType> operation;

  @override
  bool get isLoading => true;

  const LoaderLoadingState(this.operation) : super();

  @override
  List<Object?> get props => [operation.value];
}

/// State that indicates the loader is loading initial data.
final class LoaderInitialLoadingState<ResType>
    extends LoaderLoadingState<ResType> {
  const LoaderInitialLoadingState(super.operation) : super();
}

/// State that indicates the loader is refreshing data.
final class LoaderRefreshingState<ResType> extends LoaderLoadingState<ResType> {
  final ResType data;

  const LoaderRefreshingState(this.data, super.operation) : super();

  @override
  List<Object?> get props => [super.props, data];
}

/// State that indicates the loader has loaded data.
final class LoaderLoadedState<ResType> extends LoaderState<ResType> {
  final ResType data;

  const LoaderLoadedState(this.data) : super();

  @override
  List<Object?> get props => [data];
}

extension HandleAuth<ResType> on LoaderState<AuthResOrLost<ResType>> {
  T handleAuth<T>({
    T? Function(ResType)? success,
    T? Function(ResType)? refreshingAfterSuccess,
    T? Function(String)? authLost,
    T? Function(String)? refreshingAfterAuthLost,
    T? Function(AuthResOrLost<ResType>)? refreshing,
    T? Function(AuthResOrLost<ResType>)? loaded,
    T? Function()? initialLoading,
    T? Function()? initial,
    T? Function()? loading,
    required T Function() fallback,
  }) =>
      handle(
        loaded: (res) => res.handle(
          success: success,
          authLost: authLost,
          fallback: () => loaded?.call(res),
        ),
        refreshing: (res) => res.handle(
          success: refreshingAfterSuccess,
          authLost: refreshingAfterAuthLost,
          fallback: () => refreshing?.call(res),
        ),
        initialLoading: initialLoading,
        initial: initial,
        loading: loading,
        fallback: fallback,
      );

  FutureOr<void> success(FutureOr<void> Function(ResType) success) =>
      handleAuth(
        success: success,
        fallback: () {},
      );

  T handleAllAuth<T>({
    required T Function(ResType) success,
    required T Function(ResType) refreshingAfterSuccess,
    required T Function(String) authLost,
    required T Function(String) refreshingAfterAuthLost,
    required T Function() initialLoading,
    required T Function() initial,
  }) =>
      handleAuth(
        success: success,
        refreshingAfterSuccess: refreshingAfterSuccess,
        authLost: authLost,
        refreshingAfterAuthLost: refreshingAfterAuthLost,
        initialLoading: initialLoading,
        initial: initial,
        refreshing: (_) => throw Exception('No refreshing provided'),
        loaded: (_) => throw Exception('No loaded provided'),
        loading: () => throw Exception('No loading provided'),
        fallback: () => throw Exception('No fallback provided'),
      );

  T handleLoadingAuth<T>({
    required T Function(ResType) success,
    required T Function(String) authLost,
    required T Function() initial,
    required T Function() loading,
  }) =>
      handleAuth(
        success: success,
        authLost: authLost,
        initial: initial,
        loading: loading,
        loaded: (_) => throw Exception('No loaded provided'),
        fallback: () => throw Exception('No fallback provided'),
      );

  /// Handles the state and navigates to the login page if the session is lost.
  FutureOr<void> handleAuthLost(
    BuildContext context, {
    FutureOr<void> Function(ResType)? success,
    FutureOr<void> Function(ResType)? refreshingAfterSuccess,
    FutureOr<void> Function(String)? authLost,
    FutureOr<void> Function(String)? refreshingAfterAuthLost,
    FutureOr<void> Function(AuthResOrLost<ResType>)? refreshing,
    FutureOr<void> Function(AuthResOrLost<ResType>)? loaded,
    FutureOr<void> Function()? initialLoading,
    FutureOr<void> Function()? initial,
    FutureOr<void> Function()? loading,
    required FutureOr<void> Function() fallback,
  }) =>
      handleAuth(
        success: success,
        refreshingAfterSuccess: refreshingAfterSuccess,
        authLost: (message) {
          StyledBanner.show(message: message, error: true);
          goToLogin(context);
          return authLost?.call(message);
        },
        refreshingAfterAuthLost: refreshingAfterAuthLost,
        loaded: loaded,
        refreshing: refreshing,
        initialLoading: initialLoading,
        initial: initial,
        loading: loading,
        fallback: fallback,
      );

  /// Handles the state and navigates to the login page if the session is lost.
  FutureOr<void> handleAllAuthLost(
    BuildContext context, {
    required FutureOr<void> Function(ResType) success,
    required FutureOr<void> Function(ResType) refreshingAfterSuccess,
    required FutureOr<void> Function(String) refreshingAfterAuthLost,
    required FutureOr<void> Function() initialLoading,
    required FutureOr<void> Function() initial,
    FutureOr<void> Function(String)? authLost,
  }) =>
      handleAuthLost(
        context,
        success: success,
        refreshingAfterSuccess: refreshingAfterSuccess,
        authLost: authLost,
        refreshingAfterAuthLost: refreshingAfterAuthLost,
        initialLoading: initialLoading,
        initial: initial,
        refreshing: (_) => throw Exception('No refreshing provided'),
        loading: () => throw Exception('No loading provided'),
        loaded: (_) => throw Exception('No loaded provided'),
        fallback: () => throw Exception('No fallback provided'),
      );

  /// Handles the state and navigates to the login page if the session is lost.
  FutureOr<void> handleLoadingAuthLost(
    BuildContext context, {
    required FutureOr<void> Function(ResType) success,
    required FutureOr<void> Function() initial,
    required FutureOr<void> Function() loading,
    FutureOr<void> Function(String)? authLost,
  }) =>
      handleAuthLost(
        context,
        success: success,
        authLost: authLost,
        initial: initial,
        loading: loading,
        loaded: (_) => throw Exception('No loaded provided'),
        fallback: () => throw Exception('No fallback provided'),
      );
}

extension HandleHttpLoader<ResType> on LoaderState<HttpResponse<ResType>> {
  T handleHttp<T>({
    T? Function(ResType data, Headers headers)? success,
    T? Function(ResType data, Headers headers)? refreshingAfterOk,
    T? Function(ResType data, Headers headers)? refreshingAfterCache,
    T? Function(ResType data, Headers headers)? refreshingAfterSuccess,
    T? Function(Failure failure, Headers headers)? failure,
    T? Function(Failure failure, Headers headers)? refreshingAfterFailure,
    T? Function(HttpResponse<ResType>)? loaded,
    T? Function(HttpResponse<ResType>)? refreshing,
    T? Function()? initialLoading,
    T? Function()? initial,
    T? Function()? loading,
    required T Function() fallback,
  }) =>
      handle(
        loaded: (res) => res.handle(
          success: success,
          failure: failure,
          fallback: () => loaded?.call(res),
        ),
        refreshing: (res) => res.handle(
          success: refreshingAfterSuccess,
          failure: refreshingAfterFailure,
          fallback: () => refreshing?.call(res),
        ),
        initialLoading: initialLoading,
        initial: initial,
        loading: loading,
        fallback: fallback,
      );

  FutureOr<void> success(
          FutureOr<void> Function(ResType data, Headers headers) success) =>
      handleHttp(
        success: success,
        fallback: () {},
      );

  T handleAllHttp<T>({
    required T Function(ResType data, Headers headers) success,
    required T Function(ResType data, Headers headers) refreshingAfterSuccess,
    required T Function(ResType data, Headers headers) refreshingAfterCache,
    required T Function(Failure failure, Headers headers) failure,
    required T Function(Failure failure, Headers headers)
        refreshingAfterFailure,
    required T Function() initialLoading,
    required T Function() initial,
  }) =>
      handleHttp(
        success: success,
        refreshingAfterSuccess: refreshingAfterSuccess,
        refreshingAfterCache: refreshingAfterCache,
        failure: failure,
        refreshingAfterFailure: refreshingAfterFailure,
        initialLoading: initialLoading,
        initial: initial,
        loaded: (_) => throw Exception('No loaded provided'),
        refreshing: (_) => throw Exception('No refreshing provided'),
        loading: () => throw Exception('No loading provided'),
        fallback: () => throw Exception('No fallback provided'),
      );

  T handleLoadingHttp<T>({
    required T Function(ResType data, Headers headers) success,
    required T Function(Failure failure, Headers headers) failure,
    required T Function() loading,
    required T Function() initial,
  }) =>
      handleHttp(
        success: success,
        failure: failure,
        initial: initial,
        loading: loading,
        fallback: () => throw Exception('No fallback provided'),
      );
}

extension HandleAuthHttp<ResType>
    on LoaderState<AuthResOrLost<HttpResponse<ResType>>> {
  T handleAuthHttp<T>({
    T? Function(ResType data, Headers headers)? success,
    T? Function(ResType data, Headers headers)? refreshingAfterSuccess,
    T? Function(Failure failure, Headers headers)? failure,
    T? Function(Failure failure, Headers headers)? refreshingAfterFailure,
    T? Function(HttpResponse<ResType>)? authRes,
    T? Function(HttpResponse<ResType>)? refreshingAfterAuthRes,
    T? Function(String)? authLost,
    T? Function(String)? refreshingAfterAuthLost,
    T? Function(AuthResOrLost<HttpResponse<ResType>>)? loaded,
    T? Function(AuthResOrLost<HttpResponse<ResType>>)? refreshing,
    T? Function()? initialLoading,
    T? Function()? initial,
    T? Function()? loading,
    required T Function() fallback,
  }) =>
      handleAuth(
        success: (res) => res.handle(
          success: success,
          failure: failure,
          fallback: () => authRes?.call(res),
        ),
        refreshingAfterSuccess: (res) => res.handle(
          success: refreshingAfterSuccess,
          failure: refreshingAfterFailure,
          fallback: () => refreshingAfterAuthRes?.call(res),
        ),
        authLost: authLost,
        refreshingAfterAuthLost: refreshingAfterAuthLost,
        refreshing: refreshing,
        initialLoading: initialLoading,
        initial: initial,
        loaded: loaded,
        loading: loading,
        fallback: fallback,
      );

  FutureOr<void> success(
          FutureOr<void> Function(ResType data, Headers headers) success) =>
      handleAuthHttp(
        success: success,
        fallback: () {},
      );

  T handleAllAuthHttp<T>({
    required T Function(ResType data, Headers headers) success,
    required T Function(ResType data, Headers headers) refreshingAfterSuccess,
    required T Function(Failure failure, Headers headers) failure,
    required T Function(Failure failure, Headers headers)
        refreshingAfterFailure,
    required T Function(String) refreshingAfterAuthLost,
    required T Function(String) authLost,
    required T Function() initialLoading,
    required T Function() initial,
  }) =>
      handleAuthHttp(
        success: success,
        refreshingAfterSuccess: refreshingAfterSuccess,
        failure: failure,
        refreshingAfterFailure: refreshingAfterFailure,
        authLost: authLost,
        refreshingAfterAuthLost: refreshingAfterAuthLost,
        initialLoading: initialLoading,
        initial: initial,
        authRes: (_) => throw Exception('No authRes provided'),
        refreshingAfterAuthRes: (_) =>
            throw Exception('No refreshingAfterAuthRes provided'),
        loaded: (_) => throw Exception('No loaded provided'),
        refreshing: (_) => throw Exception('No refreshing provided'),
        loading: () => throw Exception('No loading provided'),
        fallback: () => throw Exception('No fallback provided'),
      );

  T handleLoadingAuthHttp<T>({
    required T Function(ResType data, Headers headers) success,
    required T Function(Failure failure, Headers headers) failure,
    required T Function(String) authLost,
    required T Function() loading,
    required T Function() initial,
  }) =>
      handleAuthHttp(
        success: success,
        failure: failure,
        authLost: authLost,
        initial: initial,
        loading: loading,
        loaded: (_) => throw Exception('No loaded provided'),
        fallback: () => throw Exception('No fallback provided'),
      );

  /// Handles the state and navigates to the login page if the session is lost.
  FutureOr<void> handleAuthLostHttp(
    BuildContext context, {
    FutureOr<void> Function(ResType data, Headers headers)? success,
    FutureOr<void> Function(ResType data, Headers headers)?
        refreshingAfterSuccess,
    FutureOr<void> Function(Failure failure, Headers headers)? failure,
    FutureOr<void> Function(Failure failure, Headers headers)?
        refreshingAfterFailure,
    FutureOr<void> Function(HttpResponse<ResType>)? authRes,
    FutureOr<void> Function(HttpResponse<ResType>)? refreshingAfterAuthRes,
    FutureOr<void> Function(String)? authLost,
    FutureOr<void> Function(String)? refreshingAfterAuthLost,
    FutureOr<void> Function(AuthResOrLost<HttpResponse<ResType>>)? loaded,
    FutureOr<void> Function(AuthResOrLost<HttpResponse<ResType>>)? refreshing,
    FutureOr<void> Function()? initialLoading,
    FutureOr<void> Function()? initial,
    FutureOr<void> Function()? loading,
    required FutureOr<void> Function() fallback,
  }) =>
      handleAuthHttp(
        success: success,
        refreshingAfterSuccess: refreshingAfterSuccess,
        failure: failure,
        refreshingAfterFailure: refreshingAfterFailure,
        authRes: authRes,
        refreshingAfterAuthRes: refreshingAfterAuthRes,
        authLost: (message) {
          StyledBanner.show(message: message, error: true);
          goToLogin(context);
          return authLost?.call(message);
        },
        refreshingAfterAuthLost: refreshingAfterAuthLost,
        loaded: loaded,
        refreshing: refreshing,
        initialLoading: initialLoading,
        initial: initial,
        loading: loading,
        fallback: fallback,
      );

  /// Handles the state and navigates to the login page if the session is lost.
  FutureOr<void> handleAllAuthLostHttp(
    BuildContext context, {
    required FutureOr<void> Function(ResType data, Headers headers) success,
    required FutureOr<void> Function(Failure failure, Headers headers) failure,
    required FutureOr<void> Function(ResType data, Headers headers)
        refreshingAfterSuccess,
    required FutureOr<void> Function(Failure failure, Headers headers)
        refreshingAfterFailure,
    required FutureOr<void> Function(String) refreshingAfterAuthLost,
    required FutureOr<void> Function(String) authLost,
    required FutureOr<void> Function() initialLoading,
    required FutureOr<void> Function() initial,
  }) =>
      handleAuthLostHttp(
        context,
        success: success,
        refreshingAfterSuccess: refreshingAfterSuccess,
        failure: failure,
        refreshingAfterFailure: refreshingAfterFailure,
        authLost: authLost,
        refreshingAfterAuthLost: refreshingAfterAuthLost,
        initialLoading: initialLoading,
        initial: initial,
        authRes: (_) => throw Exception('No authRes provided'),
        refreshingAfterAuthRes: (_) =>
            throw Exception('No refreshingAfterAuthRes provided'),
        loaded: (_) => throw Exception('No loaded provided'),
        refreshing: (_) => throw Exception('No refreshing provided'),
        loading: () => throw Exception('No loading provided'),
        fallback: () => throw Exception('No fallback provided'),
      );

  /// Handles the state and navigates to the login page if the session is lost.
  FutureOr<void> handleLoadingAuthLostHttp(
    BuildContext context, {
    required FutureOr<void> Function(ResType data, Headers headers) success,
    required FutureOr<void> Function(Failure failure, Headers headers) failure,
    required FutureOr<void> Function(String) authLost,
    required FutureOr<void> Function() loading,
    required FutureOr<void> Function() initial,
  }) =>
      handleAuthLostHttp(
        context,
        success: success,
        failure: failure,
        authLost: authLost,
        initial: initial,
        loading: loading,
        loaded: (_) => throw Exception('No loaded provided'),
        fallback: () => throw Exception('No fallback provided'),
      );
}
