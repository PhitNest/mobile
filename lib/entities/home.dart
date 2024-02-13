import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:parse_json/parse_json.dart';

import 'friend_request.dart';
import 'user.dart';

final class HomeData extends Equatable {
  final UserWithEmail user;
  final List<ExploreUser> explore;
  final List<FriendRequest> friendRequests;

  const HomeData({
    required this.user,
    required this.friendRequests,
    required this.explore,
  }) : super();

  factory HomeData.fromJson(dynamic json) => parse(
        HomeData.new,
        json,
        {
          'user': UserWithEmail.fromJson.required,
          'friendRequests': FriendRequest.fromJson.list,
          'explore': User.fromJson.list,
        },
      );

  @override
  List<Object?> get props => [user, friendRequests, explore];
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

  @override
  List<Object?> get props =>
      [user, receivedFriendRequests, friends, exploreUsers];
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
