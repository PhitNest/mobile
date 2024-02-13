import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_types/json.dart';

import 'friend_request.dart';
import 'user.dart';

final class HomeData extends Json {
  final userJson = Json.object('user', UserWithEmail.parser);
  final friendRequestsJson =
      Json.objectList('friendRequests', FriendRequest.parser);
  final exploreJson = Json.objectList('exploreUsers', User.parser);

  UserWithEmail get user => userJson.value;
  List<FriendRequest> get friendRequests => friendRequestsJson.value;
  List<User> get explore => exploreJson.value;

  HomeData.parse(super.json) : super.parse();

  HomeData.parser() : super();

  HomeData.populated({
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

sealed class HomeDataPicturesLoaded extends Equatable {
  final UserWithEmail user;
  final List<ExploreUser> exploreUsers;
  final List<FriendRequestWithProfilePicture> receivedFriendRequests;
  final List<FriendRequestWithProfilePicture> friends;

  const HomeDataPicturesLoaded({
    required this.user,
    required this.receivedFriendRequests,
    required this.friends,
    required this.exploreUsers,
  }) : super();

  Set<String> get friendUserIds =>
      friends.map((e) => e.friendRequest.other(user.id).id).toSet();

  Set<String> get sentRequestUserIds => receivedFriendRequests
      .map((e) => e.friendRequest.other(user.id).id)
      .toSet();

  @override
  List<Object?> get props => [
        user,
        receivedFriendRequests,
        friends,
        exploreUsers,
      ];
}

final class HomeDataLoaded extends HomeDataPicturesLoaded {
  final Image profilePicture;

  const HomeDataLoaded({
    required this.profilePicture,
    required super.user,
    required super.receivedFriendRequests,
    required super.friends,
    required super.exploreUsers,
  }) : super();

  @override
  List<Object?> get props => [...super.props, profilePicture];
}

final class FailedToLoadProfilePicture extends HomeDataPicturesLoaded {
  const FailedToLoadProfilePicture({
    required super.user,
    required super.receivedFriendRequests,
    required super.friends,
    required super.exploreUsers,
  }) : super();
}
