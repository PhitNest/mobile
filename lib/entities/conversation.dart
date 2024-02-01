import 'package:json_types/json.dart';

final class Conversation extends Json {
  final messagesJson = Json.objectList('messages', Message.parser);

  List<Message> get messages => messagesJson.value;

  Conversation.parse(super.json) : super.parse();

  Conversation.parser() : super();

  Conversation.populated({required List<Message> messages}) : super() {
    messagesJson.populate(messages);
  }

  @override
  List<JsonKey<dynamic, dynamic>> get keys => [messagesJson];
}

final class Message extends Json {
  final messageIdJson = Json.string('messageId');
  final senderIdJson = Json.string('senderId');
  final receiverIdJson = Json.string('receiverId');
  final contentJson = Json.string('content');

  String get messageId => messageIdJson.value;
  String get senderId => senderIdJson.value;
  String get receiverId => receiverIdJson.value;
  String get content => contentJson.value;

  Message.populated({
    required String messageId,
    required String senderId,
    required String receiverId,
    required String content,
  }) : super() {
    messageIdJson.populate(messageId);
    senderIdJson.populate(senderId);
    receiverIdJson.populate(receiverId);
    contentJson.populate(content);
  }

  Message.parse(super.json) : super.parse();

  Message.parser() : super();

  @override
  List<JsonKey<dynamic, dynamic>> get keys =>
      [messageIdJson, senderIdJson, receiverIdJson, contentJson];
}
