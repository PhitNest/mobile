part of 'messaging.dart';

typedef WebsocketLoaderBloc = AuthLoaderBloc<void, WebSocketChannel>;
typedef WebsocketLoaderConsumer = AuthLoaderConsumer<void, WebSocketChannel>;

typedef ConversationLoaderBloc
    = AuthLoaderBloc<void, HttpResponse<Conversation>>;
typedef ConversationLoaderConsumer
    = AuthLoaderConsumer<void, HttpResponse<Conversation>>;

extension on BuildContext {
  ConversationLoaderBloc get conversationLoaderBloc => authLoader();
}

class MessagingCubit extends Cubit<Iterable<Message>> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final WebSocketChannel connection;
  final User friend;
  final String userId;

  MessagingCubit({
    required this.userId,
    required this.friend,
    required this.connection,
    required List<Message> messages,
  }) : super(messages) {
    jumpToStart();
    connection.stream.listen(
      (event) {
        final message =
            Message.parse(jsonDecode(event as String) as Map<String, dynamic>);
        if (message.senderId == friend.id) {
          addMessage(message);
        }
      },
      onError: (dynamic e) async {
        await logError(e.toString(), userId: userId);
        StyledBanner.show(
          message: e.toString(),
          error: true,
        );
      },
    );
  }

  void jumpToStart() {
    Future.delayed(
        const Duration(milliseconds: 100),
        () =>
            scrollController.jumpTo(scrollController.position.maxScrollExtent));
  }

  Future<void> submit() async {
    if (messageController.text.isNotEmpty) {
      try {
        final message = messageController.text;
        connection.sink.add(jsonEncode({
          'action': 'send-message',
          'data': jsonEncode({
            'receiverId': friend.id,
            'content': messageController.text,
          }),
        }));

        addMessage(Message.populated(
          receiverId: friend.id,
          messageId: state.length,
          senderId: userId,
          content: message,
        ));
        messageController.clear();
      } catch (e) {
        await logError(e.toString(), userId: userId);
        StyledBanner.show(message: e.toString(), error: true);
      }
    }
  }

  void addMessage(Message message) {
    final messages = state.toList();
    messages.add(message);
    emit(messages);
    jumpToStart();
  }

  @override
  Future<void> close() {
    connection.sink.close();
    messageController.dispose();
    scrollController.dispose();
    return super.close();
  }
}
