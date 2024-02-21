part of 'loader.dart';

/// Base class for all loader states.
sealed class LoaderState<ResType> extends Equatable {
  const LoaderState() : super();

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
      case LoaderInitialState() || LoaderLoadedState():
    }
    return fallback();
  }

  /// Returns a widget or a builder based on the state of the loader.
  Widget loaderOr(Widget child) =>
      handle(loading: () => const Loader(), fallback: () => child);

  List<Widget> loaderOrList(List<Widget> children) =>
      handle(loading: () => const [Loader()], fallback: () => children);
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

  const LoaderLoadingState(this.operation) : super();

  @override
  List<Object?> get props => [operation];
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
