import 'package:mobile/util/util.dart';
import 'package:test/test.dart';

void main() {
  test(
    'createUrl helper',
    () {
      expect(
        createUrl('https://something.test.com', '', ''),
        'https://something.test.com',
      );
      expect(
        createUrl('https://something.test.com', '', '/test'),
        'https://something.test.com/test',
      );

      expect(
        createUrl('https://something.test.com', '443', ''),
        'https://something.test.com',
      );

      expect(
        createUrl('https://something.test.com', '443', '/hello/goodbye'),
        'https://something.test.com/hello/goodbye',
      );

      expect(
        createUrl('https://something.test.com', '80', ''),
        'https://something.test.com',
      );

      expect(
        createUrl('https://something.test.com', '80', 'testRoute'),
        'https://something.test.comtestRoute',
      );

      expect(
        createUrl('https://something.test.com', '444', 'testRoute'),
        'https://something.test.com:444testRoute',
      );

      expect(
        createUrl('https://something.test.com', 'hello', '/test/me'),
        'https://something.test.com:hello/test/me',
      );

      expect(
        createUrl('https://something.test.com', '-', 'suffix'),
        'https://something.test.com:-suffix',
      );
    },
  );
}
