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
                                          MessagingWidget(
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
  const MessagingWidget(
      {super.key,
      required this.userId,
      required this.friend,
      required this.connection,
      required this.initialMessages});

  final String userId;
  final User friend;
  final WebSocketChannel connection;
  final List<Message> initialMessages;

  @override
  Widget build(BuildContext context) {
    return MessagingProvider(
      createControllers: (_) => MessagingControllers(messages: initialMessages),
      createLoader: (_) => LoaderBloc(
          load: (requestData) => Future<HttpResponse<void>>.value(
              const HttpResponseOk(null, null))),
      createConsumer: (context, controllers, _) => LoaderConsumer(
        listener: (context, loaderState) {},
        builder: (context, loaderState) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => afterBuild(controllers));
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controllers.messages.length,
                  itemBuilder: (context, i) => Align(
                    alignment: controllers.messages[i].senderId == userId
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        controllers.messages[i].content,
                        textAlign: controllers.messages[i].senderId == userId
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controllers.messageController,
                      onSubmitted: (_) => submit(controllers),
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.grey,
                    ),
                    onPressed: () => submit(controllers),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> submit(MessagingControllers controllers) async {
    if (controllers.messageController.text.isNotEmpty) {
      try {
        final message = controllers.messageController.text;
        connection.sink.add(jsonEncode({
          'action': 'send-message',
          'data': jsonEncode({
            'receiverId': friend.id,
            'content': message,
          }),
        }));
        controllers.messages.add(Message.populated(
          receiverId: friend.id,
          messageId: controllers.messages.length,
          senderId: userId,
          content: message,
        ));
        controllers.messageController.clear();
      } catch (e) {
        await logError(e.toString(), userId: userId);
        StyledBanner.show(message: e.toString(), error: true);
      }
    }
  }

  void afterBuild(MessagingControllers controllers) {
    controllers.subscription = connection.stream.listen(
      (event) {
        final message =
            Message.parse(jsonDecode(event as String) as Map<String, dynamic>);
        if (message.senderId == friend.id) {
          controllers.messages.add(message);
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
}
