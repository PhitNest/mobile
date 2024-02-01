import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../config/aws.dart';
import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../theme.dart';
import '../../util/bloc/bloc.dart';
import '../../util/http/http.dart';
import '../../widgets/widgets.dart';
import '../login/login.dart';

part 'bloc.dart';

final class MessagingPage extends StatelessWidget {
  final User friend;

  const MessagingPage({
    super.key,
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
              LoaderLoadedState(data: final connection) => BlocProvider(
                  create: (context) => ConversationLoaderBloc(
                    sessionLoader: context.sessionLoader,
                    loadOnStart: const LoadOnStart(null),
                    load: (_, session) => conversation(friend.id, session),
                  ),
                  child: ConversationLoaderConsumer(
                    listener: (context, conversationLoaderState) {
                      switch (conversationLoaderState) {
                        case LoaderLoadedState(data: final response):
                          switch (response) {
                            case AuthRes(data: final response):
                              switch (response) {
                                case HttpResponseFailure(
                                    failure: final failure
                                  ):
                                  StyledBanner.show(
                                      message: failure.message, error: true);
                                  context.conversationLoaderBloc
                                      .add(const LoaderLoadEvent(null));
                                case HttpResponseSuccess():
                              }
                            case AuthLost(message: final message):
                              StyledBanner.show(message: message, error: true);
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute<void>(
                                      builder: (context) => const LoginPage()),
                                  (_) => false);
                          }
                        default:
                      }
                    },
                    builder: (context, conversationLoaderState) =>
                        switch (conversationLoaderState) {
                      LoaderLoadedState(data: final authRes) => switch (
                            authRes) {
                          AuthRes(data: final response) => switch (response) {
                              HttpResponseSuccess(data: final conversation) =>
                                ListView.builder(
                                  itemCount: conversation.messages.length,
                                  itemBuilder: (context, i) =>
                                      Text(conversation.messages[i].content),
                                ),
                              _ => const Loader(),
                            },
                          _ => const Loader(),
                        },
                      _ => const Loader(),
                    },
                  ),
                ),
              _ => const Loader(),
            },
          )));
}
