import 'package:flutter/cupertino.dart';

import '../../../../entities/entities.dart';
import '../../../../theme.dart';
import '../../../messaging/messaging.dart';

part 'bloc.dart';

class ConversationsPage extends StatelessWidget {
  final String userId;
  final List<FriendRequestWithProfilePicture> friends;

  const ConversationsPage({
    super.key,
    required this.userId,
    required this.friends,
  }) : super();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            Text(
              'Messages',
              style: theme.textTheme.bodyLarge,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    friends[i].friendRequest.other(userId).fullName,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class ConversationWidget extends StatelessWidget {
  final FriendRequestWithProfilePicture friend;

  const ConversationWidget({
    super.key,
    required this.friend,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Text(
          friend.friendRequest.sender.fullName,
          style: theme.textTheme.bodyMedium,
        ),
        onTap: () => Navigator.push(
            context,
            CupertinoPageRoute<void>(
                builder: (context) => const MessagingPage())),
      );
}
