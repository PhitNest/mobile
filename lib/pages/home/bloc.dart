part of 'home.dart';

typedef ExploreProfilePicturesBloc
    = AuthLoaderBloc<List<User>, List<ExploreUser>>;
typedef ExploreProfilePicturesConsumer
    = AuthLoaderConsumer<List<User>, List<ExploreUser>>;

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

typedef ProfilePictureBloc = AuthLoaderBloc<User, Image?>;
typedef ProfilePictureConsumer = AuthLoaderConsumer<User, Image?>;
typedef LogoutBloc = AuthLoaderBloc<void, void>;
typedef LogoutConsumer = AuthLoaderConsumer<void, void>;

extension HomeBlocGetters on BuildContext {
  LogoutBloc get logoutBloc => authLoader();
  HomeBloc get homeBloc => authLoader();
  SendFriendRequestBloc get sendFriendRequestBloc => authParallelBloc();
  SendReportBloc get sendReportBloc => authParallelBloc();
  DeleteUserBloc get deleteUserBloc => authLoader();
  ProfilePictureBloc get profilePictureBloc => authLoader();
  ExploreProfilePicturesBloc get exploreProfilePicturesBloc => authLoader();
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
        final profilePictureBloc = context.profilePictureBloc;
        profilePictureBloc.state.handleAuth(
          initial: () => profilePictureBloc.add(LoaderLoadEvent(response.user)),
          fallback: () {},
        );

        final exploreProfilePicturesBloc = context.exploreProfilePicturesBloc;
        exploreProfilePicturesBloc.state.handleAuth(
          initial: () =>
              exploreProfilePicturesBloc.add(LoaderLoadEvent(response.explore)),
          success: (exploreUsers) => exploreProfilePicturesBloc.add(
              LoaderSetEvent(AuthRes(response.explore
                  .map((user) => exploreUsers
                      .firstWhere((element) => element.user.id == user.id))
                  .toList()))),
          fallback: () {},
        );

        context.navBarBloc
            .add(NavBarSetNumAlertsEvent(response.pendingRequests.length));
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
      response.handleAuthLostHttp(
        context,
        success: (response, headers) {
          if (response.accepted) {
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
                      friends: [...homeData.friends, response],
                    ),
                    headers,
                  ),
                ),
              ),
            );
            context.navBarBloc.add(const NavBarReverseEvent());
          } else {
            StyledBanner.show(message: 'Friend request sent', error: false);
            context.homeBloc.add(
              LoaderSetEvent(
                AuthRes(
                  HttpResponseOk(
                    HomeResponse(
                      explore: [...homeData.explore]..remove(loaderState.req),
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
        },
        failure: (failure, _) {
          StyledBanner.show(
            message: failure.message,
            error: true,
          );
          context.navBarBloc.add(const NavBarSetLoadingEvent(false));
        },
        fallback: () {},
      );
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
      response.handleAuthLostHttp(
        context,
        success: (_, headers) {
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
                    pendingRequests: [...homeData.pendingRequests]..removeWhere(
                        (element) =>
                            element.other(homeData.user.id).id == req.user.id),
                    friends: homeData.friends,
                  ),
                  headers,
                ),
              ),
            ),
          );
          context.navBarBloc.add(const NavBarSetLoadingEvent(false));
        },
        failure: (failure, _) {
          StyledBanner.show(
            message: failure.message,
            error: true,
          );
          context.navBarBloc.add(const NavBarSetLoadingEvent(false));
        },
        fallback: () {},
      );
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
