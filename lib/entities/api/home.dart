import 'package:equatable/equatable.dart';
import 'package:parse_json/parse_json.dart';

import 'friend_request.dart';
import 'user.dart';

final class HomeResponse extends Equatable {
  final UserWithEmail user;
  final List<User> explore;
  final List<FriendRequest> pendingRequests;
  final List<FriendRequest> friends;

  const HomeResponse({
    required this.user,
    required this.explore,
    required this.pendingRequests,
    required this.friends,
  }) : super();

  factory HomeResponse.fromJson(dynamic json) => parse(
        HomeResponse.new,
        json,
        {
          'user': UserWithEmail.fromJson.required,
          'explore': User.fromJson.list,
          'pendingRequests': FriendRequest.fromJson.list,
          'friends': FriendRequest.fromJson.list,
        },
      );

  @override
  List<Object?> get props => [user, explore, pendingRequests, friends];
}
