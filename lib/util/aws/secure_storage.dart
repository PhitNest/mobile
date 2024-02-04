import 'package:amazon_cognito_identity_dart_2/cognito.dart';

import '../cache/cache.dart';

final class SecureCognitoStorage extends CognitoStorage {
  final Set<String> keyList = {};

  @override
  Future<void> clear() async {
    for (final key in keyList) {
      await cacheSecureString(key, null);
    }
  }

  @override
  Future<String?> getItem(String key) async {
    keyList.add(key);
    return getSecureCachedString(key);
  }

  @override
  Future<String?> removeItem(String key) async {
    keyList.remove(key);
    final res = getSecureCachedString(key);
    cacheSecureString(key, null);
    return res;
  }

  @override
  Future<void> setItem(String key, covariant String? value) {
    keyList.add(key);
    return cacheSecureString(key, value);
  }
}
