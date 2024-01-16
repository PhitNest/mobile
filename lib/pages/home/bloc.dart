part of 'home.dart';

typedef SendFriendRequestBloc
    = AuthParallelLoaderBloc<ExploreUser, HttpResponse<FriendRequest>>;
typedef SendFriendRequestConsumer
    = AuthParallelLoaderConsumer<ExploreUser, HttpResponse<FriendRequest>>;

typedef DeleteUserBloc = AuthLoaderBloc<void, HttpResponse<bool>>;
typedef DeleteUserConsumer = AuthLoaderConsumer<void, HttpResponse<bool>>;

typedef UserBloc
    = AuthLoaderBloc<void, HttpResponse<GetUserResponseWithExplorePictures>>;
typedef UserConsumer = AuthLoaderConsumer<void,
    HttpResponse<GetUserResponseWithExplorePictures>>;

extension HomeBlocGetters on BuildContext {
  UserBloc get userBloc => authLoader();
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

Future<void> _handleGetUserStateChanged(
  BuildContext context,
  LoaderState<AuthResOrLost<HttpResponse<GetUserResponseWithExplorePictures>>>
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
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(
                message: failure.message,
                error: true,
              );
              context.userBloc.add(const LoaderLoadEvent(null));
            case HttpResponseSuccess(data: final response):
              switch (response) {
                case GetUserSuccess(
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
                  final userBloc = context.userBloc;
                  while (image == null) {
                    image = await Navigator.push(
                      context,
                      CupertinoPageRoute<Image>(
                        builder: (_) => const PhotoInstructionsPage(),
                      ),
                    );
                  }
                  userBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                      GetUserSuccess(
                        user: response.user,
                        exploreUsers: response.exploreUsers,
                        sentFriendRequests: response.sentFriendRequests,
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
  GetUserSuccess getUserSuccess,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response, req: final req):
      switch (response) {
        case AuthRes(data: final data):
          switch (data) {
            case HttpResponseSuccess(data: final data):
              if (data.accepted) {
                StyledBanner.show(
                  message: 'Friend request accepted',
                  error: false,
                );
                context.userBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                    GetUserSuccess(
                      user: getUserSuccess.user,
                      profilePicture: getUserSuccess.profilePicture,
                      exploreUsers: getUserSuccess.exploreUsers,
                      sentFriendRequests: getUserSuccess.sentFriendRequests,
                      receivedFriendRequests:
                          getUserSuccess.receivedFriendRequests
                            ..removeWhere(
                              (element) =>
                                  element.friendRequest
                                      .other(getUserSuccess.user.id)
                                      .id ==
                                  data.other(getUserSuccess.user.id).id,
                            ),
                      friends: getUserSuccess.friends
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
                context.userBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                    GetUserSuccess(
                      exploreUsers: getUserSuccess.exploreUsers
                        ..removeWhere(
                          (element) =>
                              element.user.id ==
                              data.other(getUserSuccess.user.id).id,
                        ),
                      sentFriendRequests: getUserSuccess.sentFriendRequests
                        ..add(
                          FriendRequestWithProfilePicture(
                            friendRequest: data,
                            profilePicture: req.profilePicture,
                          ),
                        ),
                      receivedFriendRequests:
                          getUserSuccess.receivedFriendRequests
                            ..removeWhere(
                              (element) =>
                                  element.friendRequest
                                      .other(getUserSuccess.user.id)
                                      .id ==
                                  data.other(getUserSuccess.user.id).id,
                            ),
                      friends: getUserSuccess.friends,
                      user: getUserSuccess.user,
                      profilePicture: req.profilePicture,
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
