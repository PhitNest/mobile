import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/constants.dart';
import '../../../../entities/entities.dart';
import '../../../../util/bloc/bloc.dart';
import '../../../../util/http/http.dart';
import '../../../../util/logger.dart';
import '../../home.dart';
import '../styled_indicator.dart';
import 'widgets/widgets.dart';

part 'bloc.dart';

class NavBarConsumer extends StatelessWidget {
  static const double kHeight = 66;

  final Widget Function(BuildContext context, NavBarState state) builder;
  final PageController pageController;

  const NavBarConsumer({
    super.key,
    required this.builder,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) => BlocConsumer<NavBarBloc, NavBarState>(
        listener: (context, navBarState) => _handleNavBarStateChanged(
          context,
          pageController,
          navBarState,
        ),
        builder: (context, state) {
          final reversed = state is NavBarReversedState;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(child: builder(context, state)),
              Container(
                height: NavBarConsumer.kHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: reversed ? Colors.black : Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8.5,
                      spreadRadius: 0.0,
                      color: Colors.black,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: NavBarLogo(state: state),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StyledIndicator(
                            offset: const Size(8, 8),
                            count: state.numAlerts,
                            child: NavBarPageButton(
                              text: 'FRIENDS',
                              selected: state.page == NavBarPage.chat,
                              reversed: reversed,
                              onPressed: () => context.navBarBloc.add(
                                  const NavBarPressPageEvent(NavBarPage.chat)),
                            ),
                          ),
                          NavBarPageButton(
                            text: 'EXPLORE',
                            selected: state.page == NavBarPage.explore,
                            reversed: reversed,
                            onPressed: () => context.navBarBloc.add(
                                const NavBarPressPageEvent(NavBarPage.explore)),
                          ),
                          NavBarPageButton(
                            text: '',
                            selected: state.page == NavBarPage.news,
                            reversed: reversed,
                            onPressed: () {},
                          ),
                          NavBarPageButton(
                            text: 'OPTIONS',
                            selected: state.page == NavBarPage.options,
                            reversed: reversed,
                            onPressed: () => context.navBarBloc.add(
                                const NavBarPressPageEvent(NavBarPage.options)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
}
