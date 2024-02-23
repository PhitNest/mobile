part of 'home.dart';

typedef SendFriendRequestBloc
    = AuthParallelLoaderBloc<User, HttpResponse<FriendRequest>>;
typedef SendFriendRequestConsumer
    = AuthParallelLoaderConsumer<User, HttpResponse<FriendRequest>>;

typedef Report = ({User user, String reason});
typedef SendReportBloc = AuthParallelLoaderBloc<Report, HttpResponse<void>>;
typedef SendReportConsumer
    = AuthParallelLoaderConsumer<Report, HttpResponse<void>>;

typedef DeleteUserBloc = AuthLoaderBloc<void, HttpResponse<bool>>;
typedef DeleteUserConsumer = AuthLoaderConsumer<void, HttpResponse<bool>>;

typedef HomeBloc = AuthLoaderBloc<void, HttpResponse<HomeResponse>>;
typedef HomeConsumer = AuthLoaderConsumer<void, HttpResponse<HomeResponse>>;

typedef ProfilePictureBloc = AuthLoaderBloc<void, Image?>;
typedef ProfilePictureConsumer = AuthLoaderConsumer<void, Image?>;
typedef LogoutBloc = AuthLoaderBloc<void, void>;
typedef LogoutConsumer = AuthLoaderConsumer<void, void>;

extension HomeBlocGetters on BuildContext {
  LogoutBloc get logoutBloc => authLoader();
  HomeBloc get homeBloc => authLoader();
  SendFriendRequestBloc get sendFriendRequestBloc => authParallelBloc();
  SendReportBloc get sendReportBloc => authParallelBloc();
  DeleteUserBloc get deleteUserBloc => authLoader();
  ProfilePictureBloc get profilePictureBloc => authLoader();
}

void _handleLogoutState(
  BuildContext context,
  LoaderState<void> loaderState,
) =>
    loaderState.handle(
      loaded: (_) => Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => const LoginPage(),
        ),
        (_) => false,
      ),
      fallback: () {},
    );

void _handleHomeDataState(
  BuildContext context,
  LoaderState<AuthResOrLost<HttpResponse<HomeResponse>>> loaderState,
) =>
    loaderState.handleAuthLostHttp(
      context,
      success: (response, _) {
        final navbarBloc = context.navBarBloc;
        navbarBloc
            .add(NavBarSetNumAlertsEvent(response.pendingRequests.length));
        switch (navbarBloc.state) {
          case NavBarInitialState(page: final page):
            if (page == NavBarPage.explore && response.explore.isNotEmpty) {
              navbarBloc.add(const NavBarAnimateEvent());
            } else {
              navbarBloc.add(const NavBarSetLoadingEvent(false));
            }
          default:
        }
      },
      failure: (failure, _) {
        StyledBanner.show(
          message: failure.message,
          error: true,
        );
        context.homeBloc.add(const LoaderLoadEvent(null));
      },
      fallback: () {},
    );

void _handleProfilePictureState(
  BuildContext context,
  LoaderState<AuthResOrLost<Image?>> loaderState,
) =>
    loaderState.handleAuthLost(
      context,
      success: (photo) async {
        if (photo == null) {
          Image? image;
          final profilePictureBloc = context.profilePictureBloc;
          while (image == null) {
            image = await Navigator.push(
              context,
              CupertinoPageRoute<Image>(
                builder: (_) => const PhotoInstructionsPage(),
              ),
            );
          }
          profilePictureBloc.add(LoaderSetEvent(AuthRes(image)));
        }
      },
      fallback: () {},
    );

void _handleDeleteUserState(
  BuildContext context,
  LoaderState<AuthResOrLost<HttpResponse<bool>>> loaderState,
) =>
    loaderState.handleAuthLostHttp(
      context,
      success: (deleted, _) {
        if (deleted) {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => const LoginPage(),
            ),
            (_) => false,
          );
        } else {
          StyledBanner.show(
            message: 'Failed to delete user',
            error: true,
          );
        }
      },
      failure: (failure, _) =>
          StyledBanner.show(message: failure.message, error: true),
      fallback: () {},
    );

void _handleSendFriendRequestState(
  BuildContext context,
  ParallelLoaderBaseState<User, AuthResOrLost<HttpResponse<FriendRequest>>>
      loaderState,
  HomeResponse homeData,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response, req: final req):
      switch (response) {
        case AuthRes(data: final data):
          switch (data) {
            case HttpResponseSuccess(data: final data, headers: final headers):
              if (data.accepted) {
                context.homeBloc.add(
                  LoaderSetEvent(
                    AuthRes(
                      HttpResponseOk(
                        HomeResponse(
                          user: homeData.user,
                          explore: [...homeData.explore]..remove(req),
                          pendingRequests: [...homeData.pendingRequests]
                            ..removeWhere((element) =>
                                element.other(homeData.user.id).id == req.id),
                          friends: [...homeData.friends, data],
                        ),
                        headers,
                      ),
                    ),
                  ),
                );
                context.navBarBloc.add(const NavBarReverseEvent());
              } else {
                StyledBanner.show(
                  message: 'Friend request sent',
                  error: false,
                );
                context.homeBloc.add(
                  LoaderSetEvent(
                    AuthRes(
                      HttpResponseOk(
                        HomeResponse(
                          explore: [...homeData.explore]
                            ..remove(loaderState.req),
                          user: homeData.user,
                          pendingRequests: [...homeData.pendingRequests]
                            ..removeWhere((element) =>
                                element.other(homeData.user.id).id == req.id),
                          friends: homeData.friends,
                        ),
                        null,
                      ),
                    ),
                  ),
                );
                context.navBarBloc.add(const NavBarSetLoadingEvent(false));
              }
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(
                message: failure.message,
                error: true,
              );
              context.navBarBloc.add(const NavBarSetLoadingEvent(false));
          }
        case AuthLost():
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => const LoginPage(),
            ),
            (_) => false,
          );
      }
    case ParallelLoaderState():
  }
}

void _handleSendReportState(
  BuildContext context,
  ParallelLoaderBaseState<Report, AuthResOrLost<HttpResponse<void>>>
      loaderState,
  HomeResponse homeData,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response, req: final req):
      switch (response) {
        case AuthRes(data: final data):
          switch (data) {
            case HttpResponseSuccess(headers: final headers):
              StyledBanner.show(
                message: 'Report sent',
                error: false,
              );
              context.homeBloc.add(
                LoaderSetEvent(
                  AuthRes(
                    HttpResponseOk(
                      HomeResponse(
                        explore: [...homeData.explore]..remove(req.user),
                        user: homeData.user,
                        pendingRequests: [
                          ...homeData.pendingRequests
                        ]..removeWhere((element) =>
                            element.other(homeData.user.id).id == req.user.id),
                        friends: homeData.friends,
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
        case AuthLost():
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => const LoginPage(),
            ),
            (_) => false,
          );
      }
    case ParallelLoaderState():
  }
}

LogoutBloc logoutBloc(BuildContext context) => LogoutBloc(
      sessionLoader: context.sessionLoader,
      load: (_, session) async {
        context.sessionLoader.add(const LoaderSetEvent(SessionEnded()));
        await logout(session);
      },
    );
