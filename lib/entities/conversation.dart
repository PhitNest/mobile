import 'package:equatable/equatable.dart';
import 'package:parse_json/parse_json.dart';

final class Conversation extends Equatable {
  late final List<Message> messages;

  static final properties = {
    'messages': Message.fromJson.list,
  };

  Conversation({
    required List<Message> messages,
  })  : messages = messages..sort((a, b) => a.messageId.compareTo(b.messageId)),
        super();

  factory Conversation.fromJson(dynamic json) =>
      parse(Conversation.new, json, properties);

  @override
  List<Object?> get props => [messages];
}

final class Message extends Equatable {
  final int messageId;
  final String senderId;
  final String receiverId;
  final String content;

  static const properties = {
    'messageId': integer,
    'senderId': string,
    'receiverId': string,
    'content': string,
  };

  const Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
  }) : super();

  factory Message.fromJson(dynamic json) =>
      parse(Message.new, json, properties);

  @override
  List<Object?> get props => [messageId, senderId, receiverId, content];
}
