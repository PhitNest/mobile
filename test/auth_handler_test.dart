import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/pages.dart';
import 'package:mobile/util/util.dart';
import 'package:mockito/mockito.dart';

final class LoginNavigationObserver extends Mock implements NavigatorObserver {
  int numPushes = 0;
  int numRemoves = 0;

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    numRemoves++;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is CupertinoPageRoute) {
      if (route.builder(route.navigator!.context) is LoginPage) {
        numPushes++;
      }
    }
  }
}

final class MockApp extends MaterialApp {
  final LoginNavigationObserver navigationObserver;

  MockApp(
    this.navigationObserver,
    Widget Function(BuildContext context) builder, {
    super.key,
  }) : super(
            navigatorObservers: [navigationObserver],
            home: Builder(builder: builder));
}

void main() {
  const authRes = AuthRes('data');
  const authLost = AuthLost<String>('message');

  test(
    'Handling simple auth responses',
    () {
      expect(
        authRes.handle(
          success: (data) => data,
          authLost: (message) => fail('AuthLost should not be called'),
          fallback: () => fail('Fallback should not be called'),
        ),
        'data',
      );

      expect(
        authLost.handle(
          success: (data) => fail('Success should not be called'),
          authLost: (message) => message,
          fallback: () => fail('Fallback should not be called'),
        ),
        'message',
      );

      expect(
        authRes.handle(
          authLost: (message) => fail('AuthLost should not be called'),
          fallback: () => 'fallback',
        ),
        'fallback',
      );
    },
  );

  testWidgets(
    'Go to login on auth lost',
    (widgetTester) async {
      final observer = LoginNavigationObserver();
      await widgetTester.pumpWidget(MockApp(observer, (context) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => authRes.handleAuthLost(
            context,
            success: (data) => data,
            fallback: () => 'test',
          ),
        );
        return Container();
      }));
      expect(observer.numPushes, 0);
      expect(observer.numRemoves, 0);

      await widgetTester.pumpWidget(MockApp(observer, (context) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => authLost.handleAuthLost(
            context,
            success: (data) => fail('Success should not be called'),
            fallback: () => 'test',
          ),
        );
        return Container();
      }));
      expect(observer.numPushes, 1);
      expect(observer.numRemoves, 1);

      await widgetTester.pumpWidget(MockApp(observer, (context) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => authLost.handleAuthLost(
            context,
            success: (data) => fail('Success should not be called'),
            fallback: () => 'test',
          ),
        );
        return Container();
      }));
      expect(observer.numPushes, 2);
      expect(observer.numRemoves, 2);

      await widgetTester.pumpWidget(MockApp(observer, (context) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => authRes.handleAuthLost(
            context,
            success: (data) => data,
            fallback: () => 'test',
          ),
        );
        return Container();
      }));
      expect(observer.numPushes, 2);
      expect(observer.numRemoves, 2);
    },
  );

  final authResHttpSuccess =
      AuthRes<HttpResponse<String>>(HttpResponseSuccess('data', Headers()));
  final authResHttpFailure =
      AuthRes<HttpResponse<String>>(HttpResponseFailure<String>(
    const Failure(type: 'foo', message: 'message'),
    Headers(),
  ));

  const authLostHttpFailure = AuthLost<HttpResponse<String>>('lost');

  test(
    'Handling HTTP responses in auth responses',
    () {
      expect(
        authResHttpSuccess.handleHttp(
          success: (data, headers) => data,
          failure: (failure, headers) => fail('Failure should not be called'),
          authLost: (message) => fail('AuthLost should not be called'),
          fallback: () => fail('Fallback should not be called'),
        ),
        'data',
      );

      expect(
        authResHttpFailure.handleHttp(
          success: (data, headers) => fail('Success should not be called'),
          failure: (failure, headers) => failure.message,
          authLost: (message) => fail('AuthLost should not be called'),
          fallback: () => fail('Fallback should not be called'),
        ),
        'message',
      );

      expect(
        authLostHttpFailure.handleHttp(
          success: (data, headers) => fail('Success should not be called'),
          failure: (failure, headers) => fail('Failure should not be called'),
          authLost: (message) => message,
          fallback: () => fail('Fallback should not be called'),
        ),
        'lost',
      );

      expect(
        authResHttpSuccess.handleHttp(
          success: (data, headers) => null,
          fallback: () => '55',
        ),
        '55',
      );

      expect(
        authResHttpSuccess.handleHttp(
          success: (data, headers) => null,
          authRes: (res) => 200,
          failure: (failure, headers) => fail('Failure should not be called'),
          fallback: () => fail('Fallback should not be called'),
        ),
        200,
      );
    },
  );

  testWidgets(
    'Go to login on auth lost in HTTP responses',
    (widgetTester) async {
      final observer = LoginNavigationObserver();
      await widgetTester.pumpWidget(MockApp(observer, (context) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => authResHttpSuccess.handleAuthLostHttp(
            context,
            success: (data, headers) => data,
            fallback: () => 'test',
          ),
        );
        return Container();
      }));
      expect(observer.numPushes, 0);
      expect(observer.numRemoves, 0);

      await widgetTester.pumpWidget(MockApp(observer, (context) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => authLostHttpFailure.handleAuthLostHttp(
            context,
            success: (data, headers) => fail('Success should not be called'),
            fallback: () => 'test',
          ),
        );
        return Container();
      }));
      expect(observer.numPushes, 1);
      expect(observer.numRemoves, 1);

      await widgetTester.pumpWidget(MockApp(observer, (context) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => authLostHttpFailure.handleAuthLostHttp(
            context,
            success: (data, headers) => fail('Success should not be called'),
            fallback: () => 'test',
          ),
        );
        return Container();
      }));
      expect(observer.numPushes, 2);
      expect(observer.numRemoves, 2);

      await widgetTester.pumpWidget(MockApp(observer, (context) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => authResHttpSuccess.handleAuthLostHttp(
            context,
            success: (data, headers) => data,
            fallback: () => 'test',
          ),
        );
        return Container();
      }));
      expect(observer.numPushes, 2);
      expect(observer.numRemoves, 2);
    },
  );
}
