mixin ToJson {
  Map<String, dynamic> toJson();
}

extension ListToJson<T extends ToJson> on List<T> {
  List<Map<String, dynamic>> toJson() => map((e) => e.toJson()).toList();
}

extension MapToJson<K, V extends ToJson> on Map<K, V> {
  Map<K, Map<String, dynamic>> toJson() =>
      map((key, value) => MapEntry(key, value.toJson()));
}
