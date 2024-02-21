import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../../use_cases/use_cases.dart';
import '../../util/bloc/bloc.dart';
import '../../util/http/http.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';
import 'pages/pages.dart';
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
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => HomeBloc(
                  sessionLoader: context.sessionLoader,
                  load: (_, session) => homeData(session),
                  loadOnStart: const LoadOnStart(null)),
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
            BlocProvider(
              create: (context) => SendFriendRequestBloc(
                  sessionLoader: context.sessionLoader,
                  load: (user, session) => sendFriendRequest(user.id, session)),
            ),
            BlocProvider(
              create: (context) => SendReportBloc(
                sessionLoader: context.sessionLoader,
                load: (req, session) => sendReport(
                  session,
                  req.user.id,
                  req.reason,
                ),
              ),
            ),
            BlocProvider(create: (_) => NavBarBloc()),
          ],
          child: DeleteUserConsumer(
            listener: _handleDeleteUserState,
            builder: (context, deleteUserState) =>
                deleteUserState.handleAuthHttp(
              initial: () => LogoutConsumer(
                listener: _handleLogoutState,
                builder: (context, logoutState) => logoutState.handleAuth(
                  initial: () => NavBarConsumer(
                    pageController: pageController,
                    builder: (context, navBarState) => HomeConsumer(
                      listener: _handleHomeDataState,
                      builder: (context, homeLoaderState) =>
                          homeLoaderState.handleAuthHttp(
                        success: (homeLoaderResponse) => BlocProvider(
                          create: (context) => ProfilePictureBloc(
                            sessionLoader: context.sessionLoader,
                            // TODO: FIX
                            load: (_, session) => getProfilePicture(
                              session as AwsSession,
                              homeLoaderResponse.data.user.identityId,
                            ),
                          ),
                          child: ProfilePictureConsumer(
                            listener: _handleProfilePictureState,
                            builder: (context, profilePictureState) =>
                                profilePictureState.handleAuth(
                              success: (profilePicture) => profilePicture !=
                                      null
                                  ? SendReportConsumer(
                                      listener: (context, sendReportState) =>
                                          _handleSendReportState(
                                        context,
                                        sendReportState,
                                        homeLoaderResponse.data,
                                      ),
                                      builder: (context, sendReportState) =>
                                          SendFriendRequestConsumer(
                                        listener:
                                            (context, sendFriendRequestState) =>
                                                _handleSendFriendRequestState(
                                          context,
                                          sendFriendRequestState,
                                          homeLoaderResponse.data,
                                        ),
                                        builder:
                                            (context, sendFriendRequestState) =>
                                                switch (navBarState) {
                                          NavBarReversedState() => const Center(
                                              child: Text('You have matched!')),
                                          _ => switch (navBarState.page) {
                                              NavBarPage.explore => ExplorePage(
                                                  pageController:
                                                      pageController,
                                                  homeResponse:
                                                      homeLoaderResponse,
                                                  navBarState: navBarState,
                                                ),
                                              NavBarPage.chat =>
                                                ConversationsPage(
                                                  userId: homeLoaderResponse
                                                      .data.user.id,
                                                  friends: homeLoaderResponse
                                                      .data.friends,
                                                ),
                                              NavBarPage.friends => FriendsPage(
                                                  reports: sendReportState
                                                      .operations
                                                      .map((op) => op.req)
                                                      .toList(),
                                                  homeData:
                                                      homeLoaderResponse.data,
                                                ),
                                              NavBarPage.options => OptionsPage(
                                                  user: homeLoaderResponse
                                                      .data.user,
                                                  profilePicture:
                                                      profilePicture,
                                                ),
                                            },
                                        },
                                      ),
                                    )
                                  : null,
                              fallback: () => const Loader(),
                            ),
                          ),
                        ),
                        fallback: () => Center(
                          child: ListView(
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
                          ),
                        ),
                      ),
                    ),
                  ),
                  fallback: () => const Loader(),
                ),
              ),
              fallback: () => const Loader(),
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
