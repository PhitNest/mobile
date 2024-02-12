import 'package:json_types/json.dart';
import 'user.dart';

class ExploreDataModel extends Json {
  Iterable<ExploreUser> get users => [];
  ExploreDataModel.parse(super.json) : super.parse();

  const ExploreDataModel.parser() : super();

  factory ExploreDataModel.manual(Iterable<ExploreUser> newUsers) =>
      const ExploreDataModel.parser();

  @override
  List<JsonKey<dynamic, dynamic>> get keys => [];
}
