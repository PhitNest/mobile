import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../entities/entities.dart';
import '../../widgets/navbar/navbar.dart';
import 'widgets/widgets.dart';

class ExplorePage extends StatelessWidget {
  final PageController pageController;
  final NavBarState navBarState;
  final HomeResponse homeResponse;
  final Headers homeResponseHeaders;
  final List<String> loadingUserIds;
  static const PageStorageKey<String> pageStorageKey =
      PageStorageKey('explore');

  const ExplorePage({
    super.key,
    required this.homeResponse,
    required this.pageController,
    required this.homeResponseHeaders,
    required this.navBarState,
    required this.loadingUserIds,
  }) : super();

  User user(int page) =>
      homeResponse.explore[page % homeResponse.explore.length];

  @override
  Widget build(BuildContext context) => homeResponse.explore.isEmpty
      ? const Center(child: Text('There are no users to explore.'))
      : PageView.builder(
          key: pageStorageKey,
          controller: pageController,
          onPageChanged: (page) {
            final exploreUser = user(page);
            if (loadingUserIds.contains(exploreUser.id)) {
              context.navBarBloc.add(const NavBarSetLoadingEvent(true));
            } else {
              context.navBarBloc.add(const NavBarAnimateEvent());
            }
          },
          itemBuilder: (context, page) => ExploreUserPage(
            loading: loadingUserIds.contains(user(page).id),
            homeResponse: homeResponse,
            homeResponseHeaders: homeResponseHeaders,
            countdown: switch (navBarState) {
              NavBarHoldingLogoState(countdown: final countdown) => countdown,
              _ => null,
            },
            user: user(page),
            pageController: pageController,
          ),
        );
}
