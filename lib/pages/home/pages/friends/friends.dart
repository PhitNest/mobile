import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../entities/api/api.dart';
import '../../../../entities/entities.dart';
import '../../../../repositories/repositories.dart';
import '../../../../theme.dart';
import '../../../../util/bloc/bloc.dart';
import '../../../../util/http/http.dart';
import '../../../../widgets/widgets.dart';
import '../../../pages.dart';

part 'bloc.dart';

class FriendsPage extends StatelessWidget {
  final HomeResponse homeData;
  final List<Report> reports;

  const FriendsPage({
    super.key,
    required this.homeData,
    required this.reports,
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
            listener: _handleSendFriendRequestState,
            builder: (context, sendFriendRequestState) {
              final loadingIds = {
                ...sendFriendRequestState.operations.map((op) => op.req.id),
                ...deleteFriendshipState.operations
                    .map((op) => op.req.other(homeData.user.id).id),
                ...reports.map((report) => report.user.id),
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
                        itemCount: homeData.pendingRequests.length,
                        itemBuilder: (context, i) => FriendRequestWidget(
                            loading: loadingIds.contains(
                              homeData.pendingRequests[i]
                                  .other(homeData.user.id)
                                  .id,
                            ),
                            request: homeData.pendingRequests[i]),
                      ),
                    ),
                    Text(
                      'Your Friends',
                      style: theme.textTheme.bodyLarge,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: homeData.friends.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: loadingIds.contains(
                            homeData.friends[i].other(homeData.user.id).id,
                          )
                              ? const Loader()
                              : Row(
                                  children: [
                                    Text(
                                      homeData.friends[i]
                                          .other(homeData.user.id)
                                          .fullName,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    StyledOutlineButton(
                                      hPadding: 17,
                                      vPadding: 9,
                                      onPress: () => context
                                          .deleteFriendRequestBloc
                                          .add(ParallelPushEvent(
                                              homeData.friends[i])),
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
  final FriendRequest request;

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
              ? const Loader()
              : Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.sendFriendRequestBloc
                          .add(ParallelPushEvent(request.sender)),
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
                      onPress: () => context.deleteFriendRequestBloc
                          .add(ParallelPushEvent(request)),
                      text: 'IGNORE',
                    ),
                  ],
                ),
        ],
      );
}
