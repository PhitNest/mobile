import 'package:mobile/util/bloc/bloc.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Simple LoaderBloc',
    () async {
      final loaderBloc = LoaderBloc<int, int>(
        load: (number) => Future.delayed(const Duration(), () => number * 2),
      );

      expect(loaderBloc.state, const LoaderInitialState<int>());

      loaderBloc.cancel();
      expect(loaderBloc.state, const LoaderInitialState<int>());

      loaderBloc.reset();
      expect(loaderBloc.state, const LoaderInitialState<int>());

      loaderBloc.load(5);
      await loaderBloc.stream.first;
      expect(loaderBloc.state.runtimeType, LoaderInitialLoadingState<int>);

      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderLoadedState<int>(10));

      loaderBloc.load(10);
      await loaderBloc.stream.first;
      expect(loaderBloc.state.runtimeType, LoaderRefreshingState<int>);

      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderLoadedState<int>(20));

      loaderBloc.set(100);
      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderLoadedState<int>(100));

      loaderBloc.load(100);
      await loaderBloc.stream.first;
      expect(loaderBloc.state.runtimeType, LoaderRefreshingState<int>);

      loaderBloc.cancel();
      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderLoadedState<int>(100));

      loaderBloc.reset();
      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderInitialState<Never>());

      loaderBloc.load(500);
      await loaderBloc.stream.first;
      expect(loaderBloc.state.runtimeType, LoaderInitialLoadingState<int>);

      loaderBloc.cancel();
      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderInitialState<Never>());

      loaderBloc.load(500);
      await loaderBloc.stream.first;
      expect(loaderBloc.state.runtimeType, LoaderInitialLoadingState<int>);

      loaderBloc.reset();
      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderInitialState<Never>());

      loaderBloc.load(500);
      await loaderBloc.stream.first;
      expect(loaderBloc.state.runtimeType, LoaderInitialLoadingState<int>);

      loaderBloc.set(100);
      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderLoadedState<int>(100));

      loaderBloc.load(100);
      await loaderBloc.stream.first;
      expect(loaderBloc.state.runtimeType, LoaderRefreshingState<int>);

      loaderBloc.reset();
      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderInitialState<Never>());

      loaderBloc.load(500);
      await loaderBloc.stream.first;
      expect(loaderBloc.state.runtimeType, LoaderInitialLoadingState<int>);

      loaderBloc.load(1000);
      await loaderBloc.stream.first;
      expect(loaderBloc.state.runtimeType, LoaderInitialLoadingState<int>);

      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderLoadedState<int>(2000));

      loaderBloc.cancel();
      expect(loaderBloc.state, const LoaderLoadedState<int>(2000));
    },
  );

  test(
    'Dispose LoaderBloc',
    () async {
      late final int loaderDisposeState;
      final loaderBloc = LoaderBloc<int, int>(
        load: (number) async => number * 2,
        onDispose: (state) async => state.handle(
          loaded: (data) => loaderDisposeState = data,
          fallback: () => fail('Fallback should not be called'),
        ),
      );

      loaderBloc.load(5);
      await loaderBloc.stream.first;
      expect(loaderBloc.state.runtimeType, LoaderInitialLoadingState<int>);

      await loaderBloc.stream.first;
      expect(loaderBloc.state, const LoaderLoadedState<int>(10));

      await loaderBloc.close();
      expect(loaderDisposeState, 10);
    },
  );

  test(
    'Load on start',
    () async {
      final loaderLoadOnStartBloc = LoaderBloc<int, int>(
        load: (number) async => number * 2,
        loadOnStart: const LoadOnStart(1),
      );

      expect(loaderLoadOnStartBloc.state.runtimeType,
          LoaderInitialLoadingState<int>);

      await loaderLoadOnStartBloc.stream.first;
      expect(loaderLoadOnStartBloc.state, const LoaderLoadedState<int>(2));
    },
  );

  test(
    'Initial data',
    () async {
      final loaderWithInitialDataBloc = LoaderBloc<int, int>(
        load: (number) async => number * 2,
        initialData: 50,
      );

      expect(loaderWithInitialDataBloc.state, const LoaderLoadedState<int>(50));

      loaderWithInitialDataBloc.load(5);
      await loaderWithInitialDataBloc.stream.first;
      expect(loaderWithInitialDataBloc.state.runtimeType,
          LoaderRefreshingState<int>);

      await loaderWithInitialDataBloc.stream.first;
      expect(loaderWithInitialDataBloc.state, const LoaderLoadedState<int>(10));
    },
  );

  test(
    'Initial data and load on start',
    () async {
      final loaderInitialRefreshingBloc = LoaderBloc<int, int>(
        load: (number) async => number * 2,
        initialData: 50,
        loadOnStart: const LoadOnStart(1),
      );

      switch (loaderInitialRefreshingBloc.state) {
        case LoaderRefreshingState(data: final data):
          expect(data, 50);
          break;
        default:
          fail('LoaderRefreshingState should be called');
      }

      await loaderInitialRefreshingBloc.stream.first;
      expect(
          loaderInitialRefreshingBloc.state, const LoaderLoadedState<int>(2));
    },
  );
}
