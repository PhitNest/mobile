part of 'home.dart';

typedef SendFriendRequestBloc
    = AuthParallelLoaderBloc<ExploreUser, HttpResponse<FriendRequest>>;
typedef SendFriendRequestConsumer
    = AuthParallelLoaderConsumer<ExploreUser, HttpResponse<FriendRequest>>;

typedef DeleteUserBloc = AuthLoaderBloc<void, HttpResponse<bool>>;
typedef DeleteUserConsumer = AuthLoaderConsumer<void, HttpResponse<bool>>;

typedef UserBloc = AuthLoaderBloc<void, HttpResponse<HomeDataPicturesLoaded>>;
typedef UserConsumer
    = AuthLoaderConsumer<void, HttpResponse<HomeDataPicturesLoaded>>;

extension HomeBlocGetters on BuildContext {
  UserBloc get homeBloc => authLoader();
  SendFriendRequestBloc get sendFriendRequestBloc => authParallelBloc();
  DeleteUserBloc get deleteUserBloc => authLoader();
}

void _goToLogin(BuildContext context, String? error) {
  if (error != null) {
    StyledBanner.show(message: error, error: true);
  }
  Navigator.pushAndRemoveUntil(
    context,
    CupertinoPageRoute<void>(
      builder: (context) => const LoginPage(),
    ),
    (_) => false,
  );
}

void _handleLogoutStateChanged(
  BuildContext context,
  LoaderState<void> loaderState,
) {
  switch (loaderState) {
    case LoaderLoadedState():
      _goToLogin(context, null);
    default:
  }
}

Future<void> _handleHomeDataStateChanged(
  BuildContext context,
  LoaderState<AuthResOrLost<HttpResponse<HomeDataPicturesLoaded>>> loaderState,
  NavBarState navBarState,
) async {
  switch (loaderState) {
    case LoaderLoadedState(data: final response):
      switch (response) {
        case AuthLost(message: final message):
          _goToLogin(context, message);
        case AuthRes(data: final response):
          switch (response) {
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(
                message: failure.message,
                error: true,
              );
              context.homeBloc.add(const LoaderLoadEvent(null));
            case HttpResponseSuccess(data: final response):
              switch (response) {
                case HomeDataLoaded(
                    exploreUsers: final exploreUsers,
                    receivedFriendRequests: final receivedRequests,
                  ):
                  context.navBarBloc
                      .add(NavBarSetNumAlertsEvent(receivedRequests.length));
                  switch (navBarState) {
                    case NavBarInitialState(page: final page):
                      if (page == NavBarPage.explore &&
                          exploreUsers.isNotEmpty) {
                        context.navBarBloc.add(const NavBarAnimateEvent());
                      } else {
                        context.navBarBloc
                            .add(const NavBarSetLoadingEvent(false));
                      }
                    default:
                  }
                case FailedToLoadProfilePicture():
                  Image? image;
                  final userBloc = context.homeBloc;
                  while (image == null) {
                    image = await Navigator.push(
                      context,
                      CupertinoPageRoute<Image>(
                        builder: (_) => const PhotoInstructionsPage(),
                      ),
                    );
                  }
                  userBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                      HomeDataLoaded(
                        user: response.user,
                        exploreUsers: response.exploreUsers,
                        receivedFriendRequests: response.receivedFriendRequests,
                        friends: response.friends,
                        profilePicture: image,
                      ),
                      null))));
                default:
              }
          }
      }
    default:
  }
}

void _handleDeleteUserStateChanged(
  BuildContext context,
  LoaderState<AuthResOrLost<HttpResponse<bool>>> loaderState,
) {
  switch (loaderState) {
    case LoaderLoadedState(data: final response):
      switch (response) {
        case AuthRes(data: final response):
          switch (response) {
            case HttpResponseSuccess(data: final deleted):
              if (deleted) {
                _goToLogin(context, null);
              } else {
                StyledBanner.show(
                  message: 'Failed to delete user',
                  error: true,
                );
              }
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(
                message: failure.message,
                error: true,
              );
          }
        case AuthLost(message: final message):
          _goToLogin(context, message);
      }
    default:
  }
}

void _handleSendFriendRequestStateChanged(
  BuildContext context,
  ParallelLoaderState<ExploreUser, AuthResOrLost<HttpResponse<FriendRequest>>>
      loaderState,
  HomeDataLoaded homeData,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response, req: final req):
      switch (response) {
        case AuthRes(data: final data):
          switch (data) {
            case HttpResponseSuccess(data: final data):
              if (data.accepted) {
                context.homeBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                    HomeDataLoaded(
                      user: homeData.user,
                      profilePicture: homeData.profilePicture,
                      exploreUsers: homeData.exploreUsers
                        ..removeWhere((element) =>
                            element.user.id == data.other(homeData.user.id).id),
                      receivedFriendRequests: homeData.receivedFriendRequests
                        ..removeWhere(
                          (element) =>
                              element.friendRequest
                                  .other(homeData.user.id)
                                  .id ==
                              data.other(homeData.user.id).id,
                        ),
                      friends: homeData.friends
                        ..add(FriendRequestWithProfilePicture(
                            friendRequest: data,
                            profilePicture: req.profilePicture)),
                    ),
                    null))));
                context.navBarBloc.add(const NavBarReverseEvent());
              } else {
                StyledBanner.show(
                  message: 'Friend request sent',
                  error: false,
                );
                context.homeBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                    HomeDataLoaded(
                      exploreUsers: homeData.exploreUsers
                        ..removeWhere(
                          (element) =>
                              element.user.id ==
                              data.other(homeData.user.id).id,
                        ),
                      receivedFriendRequests: homeData.receivedFriendRequests
                        ..removeWhere(
                          (element) =>
                              element.friendRequest
                                  .other(homeData.user.id)
                                  .id ==
                              data.other(homeData.user.id).id,
                        ),
                      friends: homeData.friends,
                      user: homeData.user,
                      profilePicture: homeData.profilePicture,
                    ),
                    null))));
                context.navBarBloc.add(const NavBarSetLoadingEvent(false));
              }
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(
                message: failure.message,
                error: true,
              );
              context.navBarBloc.add(const NavBarSetLoadingEvent(false));
            default:
          }
        case AuthLost():
          _goToLogin(context, null);
        default:
      }
    default:
  }
}

typedef LogoutBloc = AuthLoaderBloc<void, void>;
typedef LogoutConsumer = AuthLoaderConsumer<void, void>;

extension LogoutBlocGetter on BuildContext {
  LogoutBloc get logoutBloc => authLoader();
}

LogoutBloc logoutBloc(BuildContext context) => LogoutBloc(
      sessionLoader: context.sessionLoader,
      load: (_, session) async {
        context.sessionLoader.add(const LoaderSetEvent(SessionEnded()));
        await Cognito.instance.logout(session);
      },
    );
