import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:mobile/util/util.dart';
import 'package:test/test.dart';

void main() {
  const initialState = LoaderInitialState<String>();
  final initialLoadingState =
      LoaderInitialLoadingState(CancelableOperation.fromValue('data'));
  final refreshingState =
      LoaderRefreshingState('data1', CancelableOperation.fromValue('data2'));
  const loadedState = LoaderLoadedState('data3');

  test(
    'isLoading',
    () {
      expect(initialState.isLoading, false);
      expect(initialLoadingState.isLoading, true);
      expect(refreshingState.isLoading, true);
      expect(loadedState.isLoading, false);
    },
  );

  test(
    'Handling loader states',
    () {
      expect(
        initialState.handle(
          initial: () => 100,
          loaded: (_) => fail('Loaded should not be called'),
          loading: () => fail('Loading should not be called'),
          initialLoading: () => fail('InitialLoading should not be called'),
          refreshing: (_) => fail('Refreshing should not be called'),
          fallback: () => fail('Fallback should not be called'),
        ),
        100,
      );

      expect(
        initialLoadingState.handle(
          initial: () => fail('Initial should not be called'),
          loaded: (_) => fail('Loaded should not be called'),
          loading: () => fail('Loading should not be called'),
          initialLoading: () => 400,
          refreshing: (_) => fail('Refreshing should not be called'),
          fallback: () => fail('Fallback should not be called'),
        ),
        400,
      );

      expect(
        refreshingState.handle(
          initial: () => fail('Initial should not be called'),
          loaded: (_) => fail('Loaded should not be called'),
          loading: () => fail('Loading should not be called'),
          initialLoading: () => fail('InitialLoading should not be called'),
          refreshing: (_) => 500,
          fallback: () => fail('Fallback should not be called'),
        ),
        500,
      );

      expect(
        loadedState.handle(
          initial: () => fail('Initial should not be called'),
          loaded: (_) => 200,
          loading: () => fail('Loading should not be called'),
          initialLoading: () => fail('InitialLoading should not be called'),
          refreshing: (_) => fail('Refreshing should not be called'),
          fallback: () => fail('Fallback should not be called'),
        ),
        200,
      );
    },
  );

  test(
    'Handling fallbacks',
    () {
      expect(
        initialState.handle(
          initial: () => null,
          fallback: () => 100,
        ),
        100,
      );

      expect(
        initialLoadingState.handle(
          loading: () => 100,
          fallback: () => fail('Fallback should not be called'),
        ),
        100,
      );

      expect(
        refreshingState.handle(
          fallback: () => 100,
        ),
        100,
      );

      expect(
        loadedState.handle(
          initial: () => fail('Initial should not be called'),
          fallback: () => 100,
        ),
        100,
      );

      expect(
        refreshingState.handle(
          initial: () => fail('Initial should not be called'),
          loaded: (_) => fail('Loaded should not be called'),
          loading: () => 300,
          initialLoading: () => fail('InitialLoading should not be called'),
          fallback: () => fail('Fallback should not be called'),
        ),
        300,
      );

      expect(
        initialLoadingState.handle(
          initial: () => fail('Initial should not be called'),
          loaded: (_) => fail('Loaded should not be called'),
          loading: () => 300,
          refreshing: (_) => fail('Refreshing should not be called'),
          fallback: () => fail('Fallback should not be called'),
        ),
        300,
      );
    },
  );

  final loaderhttpSuccess =
      LoaderLoadedState(HttpResponseSuccess('data1', Headers()));
  final loaderHttpFailure = LoaderLoadedState(HttpResponseFailure<String>(
    const Failure(message: 'message', type: 'code'),
    Headers(),
  ));
  const loaderHttpInitial = LoaderInitialState<HttpResponse<String>>();
  final loaderHttpInitialLoading = LoaderInitialLoadingState<
          HttpResponse<String>>(
      CancelableOperation.fromValue(HttpResponseSuccess('data3', Headers())));

  test(
    'Http Loader response handling',
    () {
      expect(
        loaderHttpInitial.handleHttp(
          initial: () => 200,
          fallback: () => fail('Fallback should not be called'),
        ),
        200,
      );

      expect(
        loaderHttpInitialLoading.handleHttp(
          initialLoading: () => 200,
          fallback: () => fail('Fallback should not be called'),
        ),
        200,
      );

      expect(
        loaderhttpSuccess.handleHttp(
          success: (data, headers) => data,
          fallback: () => fail('Fallback should not be called'),
        ),
        'data1',
      );

      expect(
        loaderHttpFailure.handleHttp(
          failure: (failure, headers) => failure.message,
          fallback: () => fail('Fallback should not be called'),
        ),
        'message',
      );

      expect(
        loaderhttpSuccess.handleHttp(
          success: (data, headers) => data,
          fallback: () => fail('Fallback should not be called'),
        ),
        'data1',
      );
    },
  );
}
