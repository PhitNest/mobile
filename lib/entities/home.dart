import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:parse_json/parse_json.dart';

import 'friend_request.dart';
import 'user.dart';

final class HomeData extends Equatable {
  final UserWithEmail user;
  final List<FriendRequest> sentRequests;
  final List<FriendRequest> receivedRequests;
  final List<User> explore;

  const HomeData({
    required this.user,
    required this.sentRequests,
    required this.receivedRequests,
    required this.explore,
  }) : super();

  factory HomeData.fromJson(dynamic json) => parse(
        HomeData.new,
        json,
        {
          'user': UserWithEmail.fromJson.required,
          'sentRequests': FriendRequest.fromJson.list,
          'receivedRequests': FriendRequest.fromJson.list,
          'explore': User.fromJson.list,
        },
      );

  @override
  List<Object?> get props => [user, sentRequests, receivedRequests, explore];
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
