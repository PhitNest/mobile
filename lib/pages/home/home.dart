import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../use_cases/use_cases.dart';
import '../../util/aws/aws.dart';
import '../../util/bloc/bloc.dart';
import '../../util/http/http.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';
import 'widgets/widgets.dart';

part 'bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key}) : super();

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

Widget _buildHome(
  BuildContext context, {
  required LoaderState<AuthResOrLost<HttpResponse<bool>>> deleteUserState,
  required LoaderState<AuthResOrLost<void>> logoutState,
  required LoaderState<
          AuthResOrLost<HttpResponse<GetUserResponseWithExplorePictures>>>
      userState,
  required Widget Function(GetUserSuccess userResponse) builder,
}) {
  final loader = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Loader(),
      StyledOutlineButton(
        onPress: () => context.logoutBloc.add(const LoaderLoadEvent(null)),
        text: 'Sign Out',
        hPadding: 16,
        vPadding: 8,
      ),
    ],
  );
  Widget homeBuilder() => switch (logoutState) {
        LoaderInitialState() => switch (userState) {
            LoaderLoadedState(data: final response) => switch (response) {
                AuthRes(data: final response) => switch (response) {
                    HttpResponseSuccess(data: final getUserResponse) => switch (
                          getUserResponse) {
                        GetUserSuccess() => builder(getUserResponse),
                        _ => loader,
                      },
                    _ => loader,
                  },
                _ => loader,
              },
            _ => loader,
          },
        _ => loader,
      };

  return switch (deleteUserState) {
    LoaderInitialState() => homeBuilder(),
    LoaderLoadedState(data: final response) => switch (response) {
        AuthRes(data: final response) => switch (response) {
            HttpResponseSuccess(data: final deleted) =>
              deleted ? const Loader() : homeBuilder(),
            HttpResponseFailure() => homeBuilder(),
          },
        _ => loader,
      },
    _ => loader,
  };
}

class _HomePageState extends State<HomePage> {
  final pageController = PageController();

  _HomePageState() : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => UserBloc(
                  sessionLoader: context.sessionLoader,
                  load: (_, session) => user(session),
                  loadOnStart: const LoadOnStart(null)),
            ),
            BlocProvider(
              create: (context) => SendFriendRequestBloc(
                  sessionLoader: context.sessionLoader,
                  load: (user, session) =>
                      sendFriendRequest(user.user.id, session)),
            ),
            const BlocProvider(create: logoutBloc),
            BlocProvider(
              create: (context) => DeleteUserBloc(
                  sessionLoader: context.sessionLoader,
                  load: (_, session) {
                    context.sessionLoader
                        .add(const LoaderSetEvent(SessionEnded()));
                    return deleteUserAccount(session);
                  }),
            ),
            BlocProvider(create: (_) => NavBarBloc()),
          ],
          child: DeleteUserConsumer(
            listener: _handleDeleteUserStateChanged,
            builder: (context, deleteUserState) => LogoutConsumer(
              listener: _handleLogoutStateChanged,
              builder: (context, logoutState) => NavBarConsumer(
                pageController: pageController,
                builder: (context, navBarState) => UserConsumer(
                  listener: (context, userState) => _handleGetUserStateChanged(
                      context, userState, navBarState),
                  builder: (context, userState) => _buildHome(
                    context,
                    deleteUserState: deleteUserState,
                    logoutState: logoutState,
                    userState: userState,
                    builder: (getUserResponse) => SendFriendRequestConsumer(
                      listener: (context, sendFriendRequestState) =>
                          _handleSendFriendRequestStateChanged(
                        context,
                        sendFriendRequestState,
                        getUserResponse,
                      ),
                      builder: (context, sendFriendRequestState) =>
                          switch (navBarState) {
                        NavBarReversedState() =>
                          const Center(child: Text('You have matched!')),
                        _ => switch (navBarState.page) {
                            NavBarPage.explore => ExplorePage(
                                pageController: pageController,
                                users: getUserResponse.exploreUsers,
                                navBarState: navBarState,
                              ),
                            NavBarPage.news => Container(),
                            NavBarPage.chat => FriendsPage(
                                initialExploreUsers:
                                    getUserResponse.exploreUsers,
                                initialFriends: getUserResponse.friends,
                                initialReceivedRequests:
                                    getUserResponse.receivedFriendRequests,
                                userId: getUserResponse.user.id,
                              ),
                            NavBarPage.options => OptionsPage(
                                user: getUserResponse.user,
                                profilePicture: getUserResponse.profilePicture,
                              ),
                          },
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
