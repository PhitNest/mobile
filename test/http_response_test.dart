import 'package:dio/dio.dart';
import 'package:mobile/util/util.dart';
import 'package:test/test.dart';

void main() {
  final httpOk = HttpResponseSuccess(
    'data',
    Headers()..set('test', '500'),
  );

  final httpFailure = HttpResponseFailure<String>(
    const Failure(type: 'foo', message: 'message'),
    Headers()..set('test2', '100'),
  );

  test(
    'Handling simple HTTP responses',
    () {
      expect(
        httpOk.handle(
          success: (data, headers) {
            expect(headers['test'], ['500']);
            return data;
          },
          fallback: () => fail('Fallback should not be called'),
        ),
        'data',
      );

      expect(
        httpFailure.handle(
          failure: (failure, headers) {
            expect(headers['test2'], ['100']);
            return failure.message;
          },
          fallback: () => fail('Fallback should not be called'),
        ),
        'message',
      );
    },
  );

  test(
    'Fallback is called properly',
    () {
      expect(
        httpFailure.handle(
          failure: (data, headers) {
            return null;
          },
          success: (data, headers) {
            return null;
          },
          fallback: () => 500,
        ),
        500,
      );
    },
  );
}
