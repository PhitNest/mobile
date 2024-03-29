import 'package:flutter/material.dart';

import 'navbar.dart';

const kLogoAnimationWidth = 8;
const kLogoWidth = 36.62;

Image _logoImage(double animation, NavBarState state) => Image.asset(
      state.logoAssetPath!,
      width: kLogoWidth + animation * kLogoAnimationWidth,
    );

final class NavBarAnimation extends StatefulWidget {
  final NavBarState state;

  const NavBarAnimation({
    super.key,
    required this.state,
  }) : super();

  @override
  NavBarAnimationState createState() => NavBarAnimationState();
}

final class NavBarAnimationState extends State<NavBarAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this)
    ..repeat(
      min: 0,
      max: 1,
      reverse: true,
      period: const Duration(milliseconds: 1200),
    );

  NavBarAnimationState() : super();

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (context, child) => _logoImage(controller.value, widget.state));

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

final class NavBarLogo extends StatelessWidget {
  final NavBarState state;

  const NavBarLogo({
    super.key,
    required this.state,
  }) : super();

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case NavBarInitialState(page: final page) ||
            NavBarSendingFriendRequestState(page: final page):
        if (page == NavBarPage.explore) {
          return const CircularProgressIndicator();
        }
      default:
    }

    return GestureDetector(
      onTapCancel: () => context.navBarBloc.add(const NavBarReleaseLogoEvent()),
      onTapDown: (_) => context.navBarBloc.add(const NavBarPressLogoEvent()),
      onTapUp: (_) => context.navBarBloc.add(const NavBarReleaseLogoEvent()),
      child: switch (state) {
        NavBarHoldingLogoState() => _logoImage(1, state),
        NavBarInactiveState() ||
        NavBarReversedState() ||
        NavBarSendingFriendRequestState() ||
        NavBarInitialState() =>
          _logoImage(0, state),
        NavBarLogoReadyState() => NavBarAnimation(state: state),
      },
    );
  }
}
