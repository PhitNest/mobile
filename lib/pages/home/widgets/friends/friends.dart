import 'package:equatable/equatable.dart';
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
  final List<FriendRequestWithProfilePicture> initialFriends;
  final List<FriendRequestWithProfilePicture> initialReceivedRequests;
  final List<ExploreUser> initialExploreUsers;

  Widget _ui(
    BuildContext context,
    FriendsPageState pageState,
    Set<String> loadingIds,
  ) =>
      Padding(
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
                itemCount: pageState.requests.length,
                itemBuilder: (context, i) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pageState.requests[i].friendRequest.sender.fullName,
                      style: theme.textTheme.bodyMedium,
                    ),
                    loadingIds.contains(
                      pageState.requests[i].friendRequest.sender.id,
                    )
                        ? const CircularProgressIndicator()
                        : Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => context.sendFriendRequestBloc
                                    .add(ParallelPushEvent(ExploreUser(
                                        user: pageState
                                            .requests[i].friendRequest.sender,
                                        profilePicture: pageState
                                            .requests[i].profilePicture))),
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
                                onPress: () => context.deleteFriendshipBloc.add(
                                    ParallelPushEvent(pageState.requests[i])),
                                text: 'IGNORE',
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            Text(
              'Your Friends',
              style: theme.textTheme.bodyLarge,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pageState.friends.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: loadingIds.contains(
                          pageState.friends[i].friendRequest.other(userId).id)
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            Text(
                              pageState.friends[i].friendRequest
                                  .other(userId)
                                  .fullName,
                              style: theme.textTheme.bodyMedium,
                            ),
                            StyledOutlineButton(
                              hPadding: 17,
                              vPadding: 9,
                              onPress: () => context.deleteFriendshipBloc
                                  .add(ParallelPushEvent(
                                pageState.friends[i],
                              )),
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

  const FriendsPage({
    super.key,
    required this.userId,
    required this.initialFriends,
    required this.initialReceivedRequests,
    required this.initialExploreUsers,
  }) : super();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DeleteFriendRequestBloc(
              sessionLoader: context.sessionLoader,
              load: (friendship, session) => deleteFriendRequest(
                  friendship.friendRequest.other(userId).id, session),
            ),
          ),
          BlocProvider(
            create: (_) => FriendRequestPageBloc(
              userId: userId,
              initialFriends: initialFriends,
              initialReceivedRequests: initialReceivedRequests,
              initialExploreUsers: initialExploreUsers,
            ),
          ),
        ],
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
              return FriendRequestPageConsumer(
                listener: _handleFriendRequestPageStateChanged,
                builder: (context, pageState) => PopScope(
                  canPop: false,
                  onPopInvoked: (didPop) {
                    if (didPop) {
                      return;
                    }
                    Navigator.of(context).pop(pageState);
                  },
                  child: _ui(context, pageState, loadingIds),
                ),
              );
            },
          ),
        ),
      );
}
