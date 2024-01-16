import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_types/json.dart';

import 'user.dart';

final class FriendRequest extends Json {
  final idJson = Json.string('id');
  final acceptedJson = Json.boolean('accepted');
  final senderJson = Json.object('sender', User.parser);
  final receiverJson = Json.object('receiver', User.parser);
  final createdAtJson = Json.string('createdAt');

  String get id => idJson.value;
  bool get accepted => acceptedJson.value;
  User get sender => senderJson.value;
  User get receiver => receiverJson.value;
  String get createdAt => createdAtJson.value;

  User other(String id) => sender.id == id ? receiver : sender;

  FriendRequest.parse(super.json) : super.parse();

  FriendRequest.parser() : super();

  FriendRequest.populated({
    required String id,
    required bool accepted,
    required User sender,
    required User receiver,
    required String createdAt,
  }) : super() {
    idJson.populate(id);
    acceptedJson.populate(accepted);
    senderJson.populate(sender);
    receiverJson.populate(receiver);
    createdAtJson.populate(createdAt);
  }

  @override
  List<JsonKey<dynamic, dynamic>> get keys =>
      [idJson, acceptedJson, senderJson, receiverJson, createdAtJson];
}

final class FriendRequestWithProfilePicture extends Equatable {
  final FriendRequest friendRequest;
  final Image profilePicture;

  const FriendRequestWithProfilePicture({
    required this.friendRequest,
    required this.profilePicture,
  }) : super();

  @override
  List<Object?> get props => [friendRequest, profilePicture];
}
