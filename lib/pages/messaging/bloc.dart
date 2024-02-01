part of 'messaging.dart';

typedef WebsocketLoaderBloc = AuthLoaderBloc<void, WebSocketChannel>;
typedef WebsocketLoaderConsumer = AuthLoaderConsumer<void, WebSocketChannel>;

typedef ConversationLoaderBloc
    = AuthLoaderBloc<void, HttpResponse<Conversation>>;
typedef ConversationLoaderConsumer
    = AuthLoaderConsumer<void, HttpResponse<Conversation>>;

extension on BuildContext {
  WebsocketLoaderBloc get websocketLoaderBloc => authLoader();
  ConversationLoaderBloc get conversationLoaderBloc => authLoader();
}
