import 'package:mobile/util/http/http.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Failure JSON deserialization',
    () {
      const failure = Failure(type: 'test', message: 'some message');
      const failureJson = {
        'type': 'test',
        'message': 'some message',
      };

      expect(Failure.fromJson(failureJson), failure);
    },
  );
}
