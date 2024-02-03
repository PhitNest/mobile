part of 'friends.dart';

typedef DeleteFriendRequestBloc = AuthParallelLoaderBloc<
    FriendRequestWithProfilePicture, HttpResponse<void>>;
typedef DeleteFriendRequestConsumer = AuthParallelLoaderConsumer<
    FriendRequestWithProfilePicture, HttpResponse<void>>;

extension on BuildContext {
  DeleteFriendRequestBloc get deleteFriendshipBloc => authParallelBloc();
}

void _handleSendFriendRequestStateChanged(
  BuildContext context,
  ParallelLoaderState<ExploreUser, AuthResOrLost<HttpResponse<FriendRequest>>>
      loaderState,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response):
      switch (response) {
        case AuthRes(data: final response):
          switch (response) {
            case HttpResponseSuccess():
              StyledBanner.show(
                message: 'Friend added',
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
  ParallelLoaderState<FriendRequestWithProfilePicture,
          AuthResOrLost<HttpResponse<void>>>
      loaderState,
  HomeDataLoaded homeData,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response, req: final req):
      switch (response) {
        case AuthRes(data: final response):
          switch (response) {
            case HttpResponseSuccess():
              if (req.friendRequest.accepted) {
                StyledBanner.show(
                  message: 'Friend removed',
                  error: false,
                );
                context.homeBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                    HomeDataLoaded(
                      user: homeData.user,
                      profilePicture: homeData.profilePicture,
                      exploreUsers: homeData.exploreUsers
                        ..add(ExploreUser(
                          user: req.friendRequest.other(homeData.user.id),
                          profilePicture: req.profilePicture,
                        )),
                      receivedFriendRequests: homeData.receivedFriendRequests,
                      friends: homeData.friends..remove(req),
                    ),
                    null))));
              }
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
