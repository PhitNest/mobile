import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../config/aws.dart';
import '../../util/bloc/bloc.dart';
import '../../util/logger.dart';

part 'bloc.dart';

final class MessagingPage extends StatelessWidget {
  const MessagingPage({
    super.key,
  }) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => WebsocketLoaderBloc(
          sessionLoader: context.sessionLoader,
          load: (_, session) async {
            final connection = WebSocketChannel.connect(
                Uri.parse('$kWebsocketUrl?authorization='
                    '${session.cognitoSession.accessToken.jwtToken}'));
            await connection.ready;
            return connection;
          }),
      child: Scaffold(
          body: WebsocketLoaderConsumer(
        listener: (context, state) {
          info(state.toString());
        },
        builder: (context, state) => Container(),
      )));
}
