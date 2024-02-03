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

final class MessagingControllers extends FormControllers {
  MessagingControllers({
    required this.messages,
  }) : super();
  final TextEditingController messageController = TextEditingController();
  late final StreamSubscription<dynamic> subscription;

  final List<Message> messages;

  @override
  void dispose() {
    messageController.dispose();
    subscription.cancel();
  }
}

typedef MessagingProvider
    = FormProvider<MessagingControllers, void, HttpResponse<void>>;
