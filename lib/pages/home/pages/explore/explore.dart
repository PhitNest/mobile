import 'package:flutter/material.dart';

import '../../../../entities/entities.dart';
import '../../../../util/http/http.dart';
import '../../widgets/navbar/navbar.dart';
import 'widgets/widgets.dart';

class ExplorePage extends StatelessWidget {
  final PageController pageController;
  final NavBarState navBarState;
  final HttpResponseSuccess<HomeResponse> homeResponse;
  static const PageStorageKey<String> pageStorageKey =
      PageStorageKey('explore');

  const ExplorePage({
    super.key,
    required this.homeResponse,
    required this.pageController,
    required this.navBarState,
  }) : super();

  @override
  Widget build(BuildContext context) => homeResponse.data.explore.isEmpty
      ? const Center(child: Text('There are no users to explore.'))
      : PageView.builder(
          key: pageStorageKey,
          controller: pageController,
          itemBuilder: (context, page) => ExploreUserPage(
            homeResponse: homeResponse,
            countdown: switch (navBarState) {
              NavBarHoldingLogoState(countdown: final countdown) => countdown,
              _ => null,
            },
            user: homeResponse
                .data.explore[page % homeResponse.data.explore.length],
            pageController: pageController,
          ),
        );
}
