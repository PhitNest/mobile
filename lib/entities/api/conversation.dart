import 'package:equatable/equatable.dart';
import 'package:parse_json/parse_json.dart';

final class Conversation extends Equatable {
  final List<Message> messages;

  static final properties = {
    'messages': Message.fromJson.list,
  };

  const Conversation({
    required this.messages,
  }) : super();

  factory Conversation.fromJson(dynamic json) =>
      parse(Conversation.new, json, properties);

  @override
  List<Object?> get props => [messages];
}

final class Message extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;

  static const properties = {
    'id': string,
    'senderId': string,
    'receiverId': string,
    'content': string,
  };

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
  }) : super();

  factory Message.fromJson(dynamic json) =>
      parse(Message.new, json, properties);

  @override
  List<Object?> get props => [id, senderId, receiverId, content];
}
