import 'package:flutter/material.dart';

import '../../../../../entities/entities.dart';
import '../../../../../util/bloc/bloc.dart';
import '../../../../pages.dart';
import '../../../widgets/navbar/navbar.dart';
import '../../../widgets/widgets.dart';
import 'report_user.dart';

final class ExploreUserPage extends StatefulWidget {
  final User user;
  final Image profilePicture;
  final int? countdown;
  final PageController pageController;
  final bool loading;

  const ExploreUserPage({
    super.key,
    required this.user,
    required this.profilePicture,
    required this.loading,
    required this.countdown,
    required this.pageController,
  }) : super();

  @override
  State<StatefulWidget> createState() => _ExploreUserPageState();
}

final class _ExploreUserPageState extends State<ExploreUserPage> {
  _ExploreUserPageState() : super();

  @override
  void initState() {
    super.initState();
    context.navBarBloc.add(widget.loading
        ? const NavBarSetLoadingEvent(true)
        : const NavBarAnimateEvent());
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                height: 444,
                width: 375,
                child: widget.profilePicture,
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    widget.pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => widget.pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ),
              ),
              // report user button
              if (!widget.loading)
                Positioned(
                  top: 16,
                  right: 16,
                  child: ReportUserButton(
                    firstName: widget.user.firstName,
                    lastName: widget.user.lastName,
                    onReportSubmitted: (reason) {
                      context.navBarBloc.add(const NavBarSetLoadingEvent(true));
                      context.sendReportBloc.add(ParallelPushEvent(
                          (reason: reason, user: widget.user)));
                    },
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  widget.countdown != null
                      ? '${widget.countdown}...'
                      : 'Press & hold the logo to send a friend request',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      );
}
