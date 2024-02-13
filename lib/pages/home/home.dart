import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entities/entities.dart';
import '../../repositories/cognito/cognito.dart';
import '../../repositories/repositories.dart';
import '../../use_cases/use_cases.dart';
import '../../util/bloc/bloc.dart';
import '../../util/http/http.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';
import 'widgets/conversations/conversations.dart';
import 'widgets/widgets.dart';

part 'bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key}) : super();

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final pageController = PageController();

  _HomePageState() : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => UserBloc(
                    sessionLoader: context.sessionLoader,
                    load: (_, session) => getHomeData(session),
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
                    listener: (context, userState) =>
                        _handleHomeDataStateChanged(
                            context, userState, navBarState),
                    builder: (context, userState) {
                      final loader = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Loader(),
                          StyledOutlineButton(
                            onPress: () => context.logoutBloc
                                .add(const LoaderLoadEvent(null)),
                            text: 'Sign Out',
                            hPadding: 16,
                            vPadding: 8,
                          ),
                        ],
                      );
                      homeBuilder() => _homeBuilder(
                            logoutState,
                            userState,
                            navBarState,
                            loader,
                          );
                      return switch (deleteUserState) {
                        LoaderInitialState() => homeBuilder(),
                        LoaderLoadedState(data: final response) => switch (
                              response) {
                            AuthRes(data: final response) => switch (response) {
                                HttpResponseSuccess(data: final deleted) =>
                                  deleted ? const Loader() : homeBuilder(),
                                HttpResponseFailure() => homeBuilder(),
                              },
                            _ => loader,
                          },
                        _ => loader,
                      };
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _homeBuilder(
          LoaderState<AuthResOrLost<void>> logoutState,
          LoaderState<AuthResOrLost<HttpResponse<HomeDataPicturesLoaded>>>
              userState,
          NavBarState navBarState,
          Column loader) =>
      switch (logoutState) {
        LoaderInitialState() => switch (userState) {
            LoaderLoadedState(data: final response) => switch (response) {
                AuthRes(data: final response) => switch (response) {
                    HttpResponseSuccess(data: final homeData) => switch (
                          homeData) {
                        HomeDataLoaded() => SendFriendRequestConsumer(
                            listener: (context, sendFriendRequestState) =>
                                _handleSendFriendRequestStateChanged(
                              context,
                              sendFriendRequestState,
                              homeData,
                            ),
                            builder: (context, sendFriendRequestState) =>
                                switch (navBarState) {
                              NavBarReversedState() =>
                                const Center(child: Text('You have matched!')),
                              _ => switch (navBarState.page) {
                                  NavBarPage.explore => ExplorePage.create(
                                      pageController: pageController,
                                      userId: homeData.user.id,
                                      friendUserIds: homeData.friendUserIds,
                                      sentRequestUserIds:
                                          homeData.sentRequestUserIds,
                                      users: homeData.exploreUsers,
                                      navBarState: navBarState),
                                  NavBarPage.chat => ConversationsPage(
                                      userId: homeData.user.id,
                                      friends: homeData.friends,
                                    ),
                                  NavBarPage.friends =>
                                    FriendsPage(homeData: homeData),
                                  NavBarPage.options => OptionsPage(
                                      user: homeData.user,
                                      profilePicture: homeData.profilePicture,
                                    ),
                                },
                            },
                          ),
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

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
