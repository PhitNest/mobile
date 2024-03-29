part of 'friends.dart';

typedef DeleteFriendRequestBloc
    = AuthParallelLoaderBloc<FriendRequest, HttpResponse<void>>;
typedef DeleteFriendRequestConsumer
    = AuthParallelLoaderConsumer<FriendRequest, HttpResponse<void>>;

extension on BuildContext {
  DeleteFriendRequestBloc get deleteFriendRequestBloc => authParallelBloc();
}

void _handleSendFriendRequestState(
  BuildContext context,
  ParallelLoaderState<User, AuthResOrLost<HttpResponse<FriendRequest>>>
      loaderState,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response):
      switch (response) {
        case AuthRes(data: final response):
          switch (response) {
            case HttpResponseSuccess():
              StyledBanner.show(
                message:
                    response.data.accepted ? 'Friend added' : 'Request sent',
                error: false,
              );
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(
                message: failure.message,
                error: true,
              );
          }
        case AuthLost(message: final message):
          StyledBanner.show(
            message: message,
            error: true,
          );
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (_) => const LoginPage(),
            ),
            (_) => false,
          );
      }
  }
}

void _handleDeleteFriendshipStateChanged(
  BuildContext context,
  ParallelLoaderState<FriendRequest, AuthResOrLost<HttpResponse<void>>>
      loaderState,
  HomeResponse homeData,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response, req: final req):
      switch (response) {
        case AuthRes(data: final response):
          switch (response) {
            case HttpResponseSuccess(headers: final headers):
              StyledBanner.show(
                message:
                    req.accepted ? 'Friend removed' : 'Friend request denied',
                error: false,
              );
              final otherUser = req.other(homeData.user.id);
              context.homeBloc.add(
                LoaderSetEvent(
                  AuthRes(
                    HttpResponseSuccess(
                      HomeResponse(
                        user: homeData.user,
                        explore: [
                          ...homeData.explore,
                          User(
                            firstName: otherUser.firstName,
                            lastName: otherUser.lastName,
                            id: otherUser.id,
                            identityId: otherUser.identityId,
                          ),
                        ],
                        pendingRequests: [
                          ...homeData.pendingRequests..remove(req)
                        ],
                        friends: [...homeData.friends]..remove(req),
                      ),
                      headers,
                    ),
                  ),
                ),
              );
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(
                message: failure.message,
                error: true,
              );
          }
        case AuthLost(message: final message):
          StyledBanner.show(
            message: message,
            error: true,
          );
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (_) => const LoginPage(),
            ),
            (_) => false,
          );
      }
  }
}
