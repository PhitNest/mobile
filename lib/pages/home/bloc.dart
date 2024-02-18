part of 'home.dart';

typedef SendFriendRequestBloc
    = AuthParallelLoaderBloc<User, HttpResponse<FriendRequest>>;
typedef SendFriendRequestConsumer
    = AuthParallelLoaderConsumer<User, HttpResponse<FriendRequest>>;

typedef DeleteUserBloc = AuthLoaderBloc<void, HttpResponse<bool>>;
typedef DeleteUserConsumer = AuthLoaderConsumer<void, HttpResponse<bool>>;

typedef HomeBloc
    = AuthLoaderBloc<void, HttpResponse<HomeResponseWithProfilePictures>>;
typedef HomeConsumer
    = AuthLoaderConsumer<void, HttpResponse<HomeResponseWithProfilePictures>>;

extension HomeBlocGetters on BuildContext {
  HomeBloc get homeBloc => authLoader();
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
  LoaderState<AuthResOrLost<HttpResponse<HomeResponseWithProfilePictures>>>
      loaderState,
  NavBarState navBarState,
) async {
  switch (loaderState) {
    case LoaderLoadedState(data: final response):
      switch (response) {
        case AuthLost(message: final message):
          _goToLogin(context, message);
        case AuthRes(data: final response):
          switch (response) {
            case HttpResponseSuccess(data: final data, headers: final headers):
              final navbarBloc = context.navBarBloc;
              if (data.profilePicture == null) {
                Image? image;
                final homeBloc = context.homeBloc;
                while (image == null) {
                  image = await Navigator.push(
                    context,
                    CupertinoPageRoute<Image>(
                      builder: (_) => const PhotoInstructionsPage(),
                    ),
                  );
                }
                homeBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                    HomeResponseWithProfilePictures(
                        explore: data.explore,
                        user: data.user,
                        profilePicture: image,
                        sentRequests: data.sentRequests,
                        receivedRequests: data.receivedRequests),
                    headers))));
              }
              navbarBloc
                  .add(NavBarSetNumAlertsEvent(data.pendingRequests.length));
              switch (navBarState) {
                case NavBarInitialState(page: final page):
                  if (page == NavBarPage.explore && data.explore.isNotEmpty) {
                    navbarBloc.add(const NavBarAnimateEvent());
                  } else {
                    navbarBloc.add(const NavBarSetLoadingEvent(false));
                  }
                default:
              }
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(
                message: failure.message,
                error: true,
              );
              context.homeBloc.add(const LoaderLoadEvent(null));
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
  ParallelLoaderState<User, AuthResOrLost<HttpResponse<FriendRequest>>>
      loaderState,
  HomeResponseWithProfilePictures homeData,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response, req: final user):
      switch (response) {
        case AuthRes(data: final data):
          switch (data) {
            case HttpResponseSuccess(data: final data):
              final request = homeData.sentRequests.firstWhere(
                  (element) => element.other(homeData.user.id).id == user.id);
              if (data.accepted) {
                context.homeBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                    HomeResponseWithProfilePictures(
                      user: homeData.user,
                      profilePicture: homeData.profilePicture,
                      explore: homeData.explore..remove(user),
                      receivedRequests: homeData.receivedRequests
                        ..remove(request)
                        ..add(FriendRequestWithProfilePicture(
                            accepted: true,
                            profilePicture: request.profilePicture,
                            sender: request.sender,
                            receiver: request.receiver,
                            createdAt: request.createdAt)),
                      sentRequests: homeData.sentRequests,
                    ),
                    null))));
                context.navBarBloc.add(const NavBarReverseEvent());
              } else {
                StyledBanner.show(
                  message: 'Friend request sent',
                  error: false,
                );
                context.homeBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                    HomeResponseWithProfilePictures(
                      explore: homeData.explore..remove(user),
                      receivedRequests: homeData.receivedRequests,
                      sentRequests: homeData.sentRequests..add(request),
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
        await logout(session);
      },
    );
