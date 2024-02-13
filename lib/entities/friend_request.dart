import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:parse_json/parse_json.dart';

import 'user.dart';

final class FriendRequest extends Equatable {
  final bool accepted;
  final User sender;
  final User receiver;
  final String createdAt;

  static final properties = <String, JsonProperty<dynamic>>{
    'accepted': boolean,
    'sender': User.fromJson.required,
    'receiver': User.fromJson.required,
    'createdAt': string,
  };

  User other(String id) => sender.id == id ? receiver : sender;

  const FriendRequest({
    required this.accepted,
    required this.sender,
    required this.receiver,
    required this.createdAt,
  }) : super();

  factory FriendRequest.fromJson(dynamic json) =>
      parse(FriendRequest.new, json, properties);

  @override
  List<Object?> get props => [accepted, sender, receiver, createdAt];
}

final class FriendRequestWithProfilePicture extends FriendRequest {
  final Image profilePicture;

  const FriendRequestWithProfilePicture({
    required super.accepted,
    required super.sender,
    required super.receiver,
    required super.createdAt,
    required this.profilePicture,
  }) : super();

  @override
  List<Object?> get props => [...super.props, profilePicture];
}
