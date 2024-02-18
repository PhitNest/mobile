import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:parse_json/parse_json.dart';

import 'friend_request.dart';
import 'user.dart';

final class Explore extends Equatable {
  final List<User> explore;

  static final properties = {
    'explore': User.fromJson.list,
  };

  const Explore({
    required this.explore,
  }) : super();

  factory Explore.fromJson(dynamic json) =>
      parse(Explore.new, json, properties);

  @override
  List<Object?> get props => [explore];
}

final class HomeResponse extends Explore {
  final UserWithEmail user;
  final List<FriendRequest> sentRequests;
  final List<FriendRequest> receivedRequests;

  const HomeResponse({
    required super.explore,
    required this.user,
    required this.sentRequests,
    required this.receivedRequests,
  }) : super();

  factory HomeResponse.fromJson(dynamic json) => parse(
        HomeResponse.new,
        json,
        {
          'user': UserWithEmail.fromJson.required,
          'sentRequests': FriendRequest.fromJson.list,
          'receivedRequests': FriendRequest.fromJson.list,
          ...Explore.properties,
        },
      );

  @override
  List<Object?> get props =>
      [...super.props, user, sentRequests, receivedRequests];
}

final class ExploreProfilePictures extends Equatable {
  final List<ExploreUser> explore;

  const ExploreProfilePictures({
    required this.explore,
  }) : super();

  @override
  List<Object?> get props => [explore];
}

final class HomeResponseWithProfilePictures extends ExploreProfilePictures {
  final UserWithEmail user;
  final Image? profilePicture;
  final List<FriendRequestWithProfilePicture> sentRequests;
  final List<FriendRequestWithProfilePicture> receivedRequests;

  List<FriendRequestWithProfilePicture> get friends => [
        ...sentRequests.where((element) => element.accepted),
        ...receivedRequests.where((element) => element.accepted),
      ];

  List<FriendRequestWithProfilePicture> get pendingRequests =>
      receivedRequests.where((element) => !element.accepted).toList();

  const HomeResponseWithProfilePictures({
    required super.explore,
    required this.user,
    required this.profilePicture,
    required this.sentRequests,
    required this.receivedRequests,
  }) : super();

  @override
  List<Object?> get props =>
      [...super.props, user, profilePicture, sentRequests, receivedRequests];
}
