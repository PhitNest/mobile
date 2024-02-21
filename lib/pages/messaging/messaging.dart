import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../config/aws.dart';
import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../theme.dart';
import '../../util/bloc/bloc.dart';
import '../../util/http/http.dart';
import '../../util/logger.dart';
import '../../widgets/widgets.dart';

part 'bloc.dart';

final class MessagingPage extends StatelessWidget {
  final String userId;
  final FriendRequest friendship;

  User get friend => friendship.other(userId);

  const MessagingPage({
    super.key,
    required this.userId,
    required this.friendship,
  }) : super();

  Future<WebSocketChannel> connectToWebsocket(
    String userId,
    String friendId,
    String accessToken,
  ) async {
    final connection = WebSocketChannel.connect(
      Uri.parse(
        '$kWebsocketUrl?friendRequestSenderId=$userId'
        '&friendRequestReceiverId=$friendId'
        '&authorization=$accessToken',
      ),
    );
    await connection.ready;
    return connection;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 32,
            ),
          ),
          title: Text(
            friend.fullName,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        body: BlocProvider(
          create: (context) => WebsocketLoaderBloc(
            sessionLoader: context.sessionLoader,
            loadOnStart: const LoadOnStart(null),
            load: (_, session) =>
                connectToWebsocket(userId, friend.id, session.accessToken),
            onDispose: (state) => state.goToLoginOr(
              context,
              success: (connection) => connection.sink.close(),
              fallback: () {},
            ),
          ),
          child: WebsocketLoaderConsumer(
            listener: (context, websocketLoaderState) =>
                websocketLoaderState.goToLoginOr(
              context,
              fallback: () {},
            ),
            builder: (context, websocketLoaderState) =>
                websocketLoaderState.handleAuth(
              success: (connection) => BlocProvider(
                create: (context) => ConversationLoaderBloc(
                  sessionLoader: context.sessionLoader,
                  loadOnStart: const LoadOnStart(null),
                  load: (_, session) => conversation(
                    friendship.sender.id,
                    friendship.receiver.id,
                    session,
                  ),
                ),
                child: ConversationLoaderConsumer(
                  listener: (context, conversationLoaderState) =>
                      conversationLoaderState.httpGoToLoginOr(
                    context,
                    failure: (response) {
                      StyledBanner.show(
                        message: response.failure.message,
                        error: true,
                      );
                      context.conversationLoaderBloc
                          .add(const LoaderLoadEvent(null));
                    },
                    fallback: () {},
                  ),
                  builder: (context, conversationLoaderState) =>
                      conversationLoaderState.handleAuthHttp(
                    success: (response) => _MessagingWidget(
                      userId: userId,
                      friend: friend,
                      connection: connection,
                      initialMessages: response.data.messages,
                    ),
                    fallback: () => const Loader(),
                  ),
                ),
              ),
              fallback: () => const Loader(),
            ),
          ),
        ),
      );
}

class _MessagingWidget extends StatelessWidget {
  final String userId;
  final User friend;
  final WebSocketChannel connection;
  final List<Message> initialMessages;

  const _MessagingWidget({
    required this.userId,
    required this.friend,
    required this.connection,
    required this.initialMessages,
  }) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => MessagingCubit(
          connection: connection,
          messages: initialMessages,
          userId: userId,
          friend: friend,
        ),
        child: BlocBuilder<MessagingCubit, Iterable<Message>>(
          builder: (context, state) {
            final cubit = BlocProvider.of<MessagingCubit>(context);
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ListView(
                  controller: cubit.scrollController,
                  reverse: true,
                  children: state
                      .map((message) => MessageItemWidget(message, userId))
                      .toList(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cubit.messageController,
                        onSubmitted: (_) => cubit.submit(),
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.grey),
                      onPressed: cubit.submit,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
}

class MessageItemWidget extends StatelessWidget {
  final String userId;

  const MessageItemWidget(
    this.message,
    this.userId, {
    super.key,
  }) : super();

  final Message message;

  @override
  Widget build(BuildContext context) => Container(
        alignment: message.senderId == userId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        padding: const EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width * 0.7,
        child: Text(
          message.content,
          textAlign:
              message.senderId == userId ? TextAlign.right : TextAlign.left,
        ),
      );
}
