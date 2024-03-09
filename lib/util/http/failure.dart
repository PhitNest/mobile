import 'package:equatable/equatable.dart';
import 'package:parse_json/parse_json.dart';

final class Failure extends Equatable {
  final String type;
  final String message;

  static const properties = {
    'type': string,
    'message': string,
  };

  const Failure({
    required this.type,
    required this.message,
  }) : super();

  factory Failure.fromJson(Map<String, dynamic> json) =>
      parse(Failure.new, json, properties);

  @override
  List<Object?> get props => [type, message];
}
