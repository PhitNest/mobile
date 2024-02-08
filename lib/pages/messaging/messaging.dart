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
import '../login/login.dart';

part 'bloc.dart';

final class MessagingPage extends StatelessWidget {
  final String userId;
  final User friend;

  const MessagingPage({
    super.key,
    required this.userId,
    required this.friend,
  }) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => WebsocketLoaderBloc(
          sessionLoader: context.sessionLoader,
          loadOnStart: const LoadOnStart(null),
          load: (_, session) async {
            final connection = WebSocketChannel.connect(
                Uri.parse('$kWebsocketUrl?authorization='
                    '${session.cognitoSession.accessToken.jwtToken}'));
            await connection.ready;
            return connection;
          },
          onDispose: (state) async {
            switch (state) {
              case LoaderLoadedState(data: final res):
                switch (res) {
                  case AuthRes(data: final connection):
                    await connection.sink.close();
                  case AuthLost():
                }
              default:
            }
          }),
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
          body: WebsocketLoaderConsumer(
              listener: (context, websocketLoaderState) {
                switch (websocketLoaderState) {
                  case LoaderLoadedState(data: final response):
                    switch (response) {
                      case AuthLost(message: final message):
                        StyledBanner.show(message: message, error: true);
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                                builder: (context) => const LoginPage()),
                            (_) => false);
                      case AuthRes():
                    }
                  default:
                }
              },
              builder: (context, websocketLoaderState) =>
                  switch (websocketLoaderState) {
                    LoaderLoadedState(data: final res) => switch (res) {
                        AuthRes(data: final connection) => BlocProvider(
                            create: (context) => ConversationLoaderBloc(
                              sessionLoader: context.sessionLoader,
                              loadOnStart: const LoadOnStart(null),
                              load: (_, session) =>
                                  conversation(friend.id, session),
                            ),
                            child: ConversationLoaderConsumer(
                              listener:
                                  (context, conversationLoaderState) async {
                                switch (conversationLoaderState) {
                                  case LoaderLoadedState(data: final response):
                                    switch (response) {
                                      case AuthRes(data: final response):
                                        switch (response) {
                                          case HttpResponseFailure(
                                              failure: final failure
                                            ):
                                            StyledBanner.show(
                                                message: failure.message,
                                                error: true);
                                            context.conversationLoaderBloc.add(
                                                const LoaderLoadEvent(null));
                                          default:
                                        }
                                      case AuthLost(message: final message):
                                        StyledBanner.show(
                                            message: message, error: true);
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute<void>(
                                                    builder: (context) =>
                                                        const LoginPage()),
                                                (_) => false);
                                    }
                                  default:
                                }
                              },
                              builder: (context, conversationLoaderState) =>
                                  switch (conversationLoaderState) {
                                LoaderLoadedState(data: final authRes) =>
                                  switch (authRes) {
                                    AuthRes(data: final response) => switch (
                                          response) {
                                        HttpResponseSuccess(
                                          data: final conversation
                                        ) =>
                                          MessagingWidget.create(
                                            userId: userId,
                                            friend: friend,
                                            connection: connection,
                                            initialMessages:
                                                conversation.messages,
                                          ),
                                        _ => const Loader()
                                      },
                                    _ => const Loader()
                                  },
                                _ => const Loader()
                              },
                            ),
                          ),
                        _ => const Loader()
                      },
                    _ => const Loader()
                  })));
}

class MessagingWidget extends StatelessWidget {
  const MessagingWidget({super.key});

  static Widget create({
    required String userId,
    required User friend,
    required WebSocketChannel connection,
    required List<Message> initialMessages,
  }) =>
      BlocProvider(
        create: (context) => MessagingCubit(
            connection: connection,
            messages: initialMessages,
            userId: userId,
            friend: friend),
        child: const MessagingWidget(),
      );

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MessagingCubit, Iterable<Message>>(
        builder: (context, state) {
          final cubit = BlocProvider.of<MessagingCubit>(context);
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: cubit.scrollController,
                    itemCount: cubit.state.length,
                    itemBuilder: (context, index) =>
                        MessageItemWidget(cubit.state.elementAt(index)),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cubit.messageController,
                        onSubmitted: (_) => cubit.submit,
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
            ),
          );
        },
      );
}

class MessageItemWidget extends StatelessWidget {
  const MessageItemWidget(this.message, {super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<MessagingCubit>(context);
    return Align(
      alignment: message.senderId == cubit.userId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width * 0.7,
        child: Text(
          message.content,
          textAlign: message.senderId == cubit.userId
              ? TextAlign.right
              : TextAlign.left,
        ),
      ),
    );
  }
}
