import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../entities/entities.dart';
import '../../../../repositories/repositories.dart';
import '../../../../theme.dart';
import '../../../../util/bloc/bloc.dart';
import '../../../../util/http/http.dart';
import '../../../../widgets/widgets.dart';
import '../../../pages.dart';

part 'bloc.dart';

class FriendsPage extends StatelessWidget {
  final String userId;
  final List<FriendRequestWithProfilePicture> requests;
  final List<FriendRequestWithProfilePicture> friends;

  const FriendsPage({
    super.key,
    required this.userId,
    required this.requests,
    required this.friends,
  }) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => DeleteFriendRequestBloc(
          sessionLoader: context.sessionLoader,
          load: (friendship, session) => deleteFriendRequest(
              friendship.friendRequest.other(userId).id, session),
        ),
        child: DeleteFriendRequestConsumer(
          listener: _handleDeleteFriendshipStateChanged,
          builder: (context, deleteFriendshipState) =>
              SendFriendRequestConsumer(
            listener: _handleSendFriendRequestStateChanged,
            builder: (context, sendFriendRequestState) {
              final loadingIds = {
                ...sendFriendRequestState.operations
                    .map((op) => op.req.user.id),
                ...deleteFriendshipState.operations
                    .map((op) => op.req.friendRequest.other(userId).id),
              };
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      'Friend requests',
                      style: theme.textTheme.bodyLarge,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: requests.length,
                        itemBuilder: (context, i) => FriendRequestWidget(
                            loading: loadingIds.contains(
                                requests[i].friendRequest.other(userId).id),
                            request: requests[i]),
                      ),
                    ),
                    Text(
                      'Your Friends',
                      style: theme.textTheme.bodyLarge,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: friends.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: loadingIds.contains(
                                  friends[i].friendRequest.other(userId).id)
                              ? const Center(child: CircularProgressIndicator())
                              : Row(
                                  children: [
                                    Text(
                                      friends[i]
                                          .friendRequest
                                          .other(userId)
                                          .fullName,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    StyledOutlineButton(
                                      hPadding: 17,
                                      vPadding: 9,
                                      onPress: () => context
                                          .deleteFriendshipBloc
                                          .add(ParallelPushEvent(friends[i])),
                                      text: 'REMOVE',
                                    )
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
}

class FriendRequestWidget extends StatelessWidget {
  final bool loading;
  final FriendRequestWithProfilePicture request;

  const FriendRequestWidget({
    super.key,
    required this.loading,
    required this.request,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            request.friendRequest.sender.fullName,
            style: theme.textTheme.bodyMedium,
          ),
          loading
              ? const CircularProgressIndicator()
              : Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.sendFriendRequestBloc.add(
                          ParallelPushEvent(ExploreUser(
                              user: request.friendRequest.sender,
                              profilePicture: request.profilePicture))),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'ACCEPT',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    StyledOutlineButton(
                      hPadding: 17,
                      vPadding: 9,
                      onPress: () => context.deleteFriendshipBloc
                          .add(ParallelPushEvent(request)),
                      text: 'IGNORE',
                    ),
                  ],
                ),
        ],
      );
}
