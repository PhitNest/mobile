import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../entities/entities.dart';
import '../../widgets/navbar/navbar.dart';
import 'widgets/widgets.dart';

final class ExploreUser extends Equatable {
  final User user;
  final Image profilePicture;

  const ExploreUser({
    required this.user,
    required this.profilePicture,
  }) : super();

  @override
  List<Object?> get props => [user, profilePicture];
}

final class ExplorePage extends StatefulWidget {
  final List<ExploreUser> exploreUsers;
  final NavBarState navBarState;
  final Set<String> loadingUserIds;
  final PageController pageController;

  const ExplorePage({
    super.key,
    required this.exploreUsers,
    required this.navBarState,
    required this.loadingUserIds,
    required this.pageController,
  }) : super();

  @override
  State<StatefulWidget> createState() => _ExplorePageLoadedState();
}

final class _ExplorePageLoadedState extends State<ExplorePage> {
  static const PageStorageKey<String> pageStorageKey =
      PageStorageKey('explore');

  _ExplorePageLoadedState() : super();

  ExploreUser user(int page) =>
      widget.exploreUsers[page % widget.exploreUsers.length];

  @override
  void initState() {
    super.initState();
    switch (widget.navBarState) {
      case NavBarInitialState():
        if (widget.exploreUsers.isEmpty) {
          context.navBarBloc.add(const NavBarSetLoadingEvent(false));
        }
      default:
    }
  }

  @override
  Widget build(BuildContext context) => widget.exploreUsers.isEmpty
      ? const Center(child: Text('There are no users to explore.'))
      : PageView.builder(
          key: pageStorageKey,
          controller: widget.pageController,
          itemBuilder: (context, page) {
            final exploreUser = user(page);
            return ExploreUserPage(
              profilePicture: exploreUser.profilePicture,
              loading: widget.loadingUserIds.contains(exploreUser.user.id),
              countdown: switch (widget.navBarState) {
                NavBarHoldingLogoState(countdown: final countdown) => countdown,
                _ => null,
              },
              user: exploreUser.user,
              pageController: widget.pageController,
            );
          },
        );
}
