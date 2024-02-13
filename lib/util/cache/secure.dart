part of 'cache.dart';

// READ METHODS:

T? _getSecureCached<T>(String key, T Function(dynamic data) parse) {
  T? val;
  final lazyLoad = _cache.lazyLoadedSecureCache[key];
  if (lazyLoad != null && lazyLoad is T) {
    val = lazyLoad;
  } else if (_cache.stringifiedSecureCache[key] != null) {
    val = parse(jsonDecode(_cache.stringifiedSecureCache[key]!));
  }
  if (val != null) {
    debug('Lazy loaded cache hit:', details: ['key: $key']);
  }
  return val;
}

T? _getPrimitive<T>(String key) => _getSecureCached(key, (json) => json as T);

String? getSecureCachedString(String key) => _getPrimitive(key);

double? getSecureCachedDouble(String key) => _getPrimitive(key);

bool? getSecureCachedBool(String key) => _getPrimitive(key);

int? getSecureCachedInt(String key) => _getPrimitive(key);

T? getSecureCachedObject<T>(String key, T Function(dynamic json) parser) =>
    _getSecureCached(key, parser.required.function);

List<String>? getSecureCachedStringList(String key) => _getPrimitive(key);

List<double>? getSecureCachedDoubleList(String key) => _getPrimitive(key);

List<bool>? getSecureCachedBoolList(String key) => _getPrimitive(key);

List<int>? getSecureCachedIntList(String key) => _getPrimitive(key);

List<T>? getSecureCachedObjectList<T>(
        String key, T Function(dynamic json) parser) =>
    _getSecureCached(key, parser.list.function);

Map<String, String>? getSecureCachedStringMap(String key) => _getPrimitive(key);

Map<String, double>? getSecureCachedDoubleMap(String key) => _getPrimitive(key);

Map<String, bool>? getSecureCachedBoolMap(String key) => _getPrimitive(key);

Map<String, int>? getSecureCachedIntMap(String key) => _getPrimitive(key);

Map<String, T>? getSecureCachedObjectMap<T>(
        String key, T Function(dynamic json) parser) =>
    _getSecureCached(key, parser.stringMap.function);

// WRITE METHODS:

Future<void> _cacheSecure(String key, Type type, dynamic value) =>
    _cache.secureCacheLock.synchronized(
      () {
        if (value != null) {
          debug('Caching secure $type:', details: ['key: $key']);
          final stringifiedValue = jsonEncode(value);
          _cache.stringifiedSecureCache[key] = stringifiedValue;
          _cache.lazyLoadedSecureCache[key] = value;
          return _cache.secureStorage.write(
            key: key,
            value: stringifiedValue,
          );
        } else {
          _cache.stringifiedSecureCache.remove(key);
          _cache.lazyLoadedSecureCache.remove(key);
          debug('Removing cached secure $type:',
              details: ['key: $key', 'Lazy loaded cache hit']);
          return _cache.secureStorage.write(
            key: key,
            value: null,
          );
        }
      },
    );

Future<void> _cachePrimitive<T>(String key, T? primitive) =>
    _cacheSecure(key, T, primitive);

Future<void> cacheSecureString(String key, String? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureDouble(String key, double? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureBool(String key, bool? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureInt(String key, int? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureObject<T extends ToJson>(String key, T? value) =>
    _cacheSecure(key, T, value?.toJson());

Future<void> cacheSecureStringList(String key, List<String>? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureDoubleList(String key, List<double>? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureBoolList(String key, List<bool>? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureIntList(String key, List<int>? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureObjectList<T extends ToJson>(
        String key, List<T>? value) =>
    _cacheSecure(key, List<T>, value?.toJson());

Future<void> cacheSecureStringMap(String key, Map<String, String>? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureDoubleMap(String key, Map<String, double>? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureBoolMap(String key, Map<String, bool>? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureIntMap(String key, Map<String, int>? value) =>
    _cachePrimitive(key, value);

Future<void> cacheSecureObjectMap<T extends ToJson>(String key, T? value) =>
    _cacheSecure(key, Map<String, T>, value?.toJson());
