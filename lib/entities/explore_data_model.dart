import 'package:equatable/equatable.dart';
import 'package:json_types/json.dart';
import 'user.dart';

final class ExploreDataModel extends Json {
  final exploreJson = Json.objectList('exploreUsers', User.parser);

  List<User> get explore => exploreJson.value;
  ExploreDataModel.parse(super.json) : super.parse();
  ExploreDataModel.parser() : super();
  @override
  List<JsonKey<dynamic, dynamic>> get keys => [exploreJson];
}

final class ExploreDataLoaded extends Equatable {
  final List<ExploreUser> exploreUsers;

  const ExploreDataLoaded({required this.exploreUsers}) : super();

  @override
  List<Object?> get props => [exploreUsers];
}
