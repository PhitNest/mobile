import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_types/json.dart';

import '../entities.dart';

final class GetUserResponse extends Json {
  final userJson = Json.object('user', UserWithEmail.parser);
  final friendRequestsJson =
      Json.objectList('friendRequests', FriendRequest.parser);
  final exploreJson = Json.objectList('exploreUsers', User.parser);

  UserWithEmail get user => userJson.value;
  List<FriendRequest> get friendRequests => friendRequestsJson.value;
  List<User> get explore => exploreJson.value;

  GetUserResponse.parse(super.json) : super.parse();

  GetUserResponse.parser() : super();

  GetUserResponse.populated({
    required UserWithEmail user,
    required List<FriendRequest> friendRequests,
    required List<User> explore,
  }) : super() {
    userJson.populate(user);
    friendRequestsJson.populate(friendRequests);
    exploreJson.populate(explore);
  }

  @override
  List<JsonKey<dynamic, dynamic>> get keys =>
      [userJson, friendRequestsJson, exploreJson];
}

sealed class GetUserResponseWithExplorePictures extends Equatable {
  final UserWithEmail user;
  final List<ExploreUser> exploreUsers;
  final List<FriendRequestWithProfilePicture> sentFriendRequests;
  final List<FriendRequestWithProfilePicture> receivedFriendRequests;
  final List<FriendRequestWithProfilePicture> friends;

  const GetUserResponseWithExplorePictures({
    required this.user,
    required this.sentFriendRequests,
    required this.receivedFriendRequests,
    required this.friends,
    required this.exploreUsers,
  }) : super();

  @override
  List<Object?> get props => [
        user,
        sentFriendRequests,
        receivedFriendRequests,
        friends,
        exploreUsers,
      ];
}

final class GetUserSuccess extends GetUserResponseWithExplorePictures {
  final Image profilePicture;

  const GetUserSuccess({
    required this.profilePicture,
    required super.user,
    required super.sentFriendRequests,
    required super.receivedFriendRequests,
    required super.friends,
    required super.exploreUsers,
  }) : super();

  @override
  List<Object?> get props => [...super.props, profilePicture];
}

final class FailedToLoadProfilePicture
    extends GetUserResponseWithExplorePictures {
  const FailedToLoadProfilePicture({
    required super.user,
    required super.sentFriendRequests,
    required super.receivedFriendRequests,
    required super.friends,
    required super.exploreUsers,
  }) : super();
}
