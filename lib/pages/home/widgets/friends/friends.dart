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
  final HomeResponseWithProfilePictures homeData;
  late final List<FriendRequestWithProfilePicture> friends = homeData.friends;
  late final List<FriendRequestWithProfilePicture> pendingRequests =
      homeData.pendingRequests;

  // ignore: prefer_const_constructors_in_immutables
  FriendsPage({
    super.key,
    required this.homeData,
  }) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => DeleteFriendRequestBloc(
          sessionLoader: context.sessionLoader,
          load: (friendship, session) => deleteFriendRequest(
              friendship.sender.id, friendship.receiver.id, session),
        ),
        child: DeleteFriendRequestConsumer(
          listener: (context, deleteFriendshipLoaderState) =>
              _handleDeleteFriendshipStateChanged(
                  context, deleteFriendshipLoaderState, homeData),
          builder: (context, deleteFriendshipState) =>
              SendFriendRequestConsumer(
            listener: _handleSendFriendRequestStateChanged,
            builder: (context, sendFriendRequestState) {
              final loadingIds = {
                ...sendFriendRequestState.operations.map((op) => op.req.id),
                ...deleteFriendshipState.operations
                    .map((op) => op.req.other(homeData.user.id).id),
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
                        itemCount: pendingRequests.length,
                        itemBuilder: (context, i) => FriendRequestWidget(
                            loading: loadingIds.contains(
                                pendingRequests[i].other(homeData.user.id).id),
                            request: pendingRequests[i]),
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
                                  friends[i].other(homeData.user.id).id)
                              ? const Center(child: CircularProgressIndicator())
                              : Row(
                                  children: [
                                    Text(
                                      friends[i]
                                          .other(homeData.user.id)
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
            request.sender.fullName,
            style: theme.textTheme.bodyMedium,
          ),
          loading
              ? const CircularProgressIndicator()
              : Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.sendFriendRequestBloc.add(
                          ParallelPushEvent(ExploreUser(
                              id: request.sender.id,
                              firstName: request.sender.firstName,
                              lastName: request.sender.lastName,
                              identityId: request.sender.identityId,
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
