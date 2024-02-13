import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../entities/entities.dart';
import '../../../../../util/bloc/bloc.dart';
import '../bloc.dart';
import 'report_user.dart';

final class ExploreUserPage extends StatelessWidget {
  final ExploreUser user;
  final int? countdown;
  final PageController pageController;

  const ExploreUserPage({
    super.key,
    required this.user,
    required this.countdown,
    required this.pageController,
  }) : super();

  void reloadUsers(BuildContext context) =>
      BlocProvider.of<ExploreBloc>(context).add(const LoaderLoadEvent(null));

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ExploreBloc, dynamic>(builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => Future(() => reloadUsers(context)),
          child: Center(
            child: ListView(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 444,
                      width: 375,
                      child: user.profilePicture,
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () {
                          pageController.previousPage(
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
                        onTap: () {
                          pageController.nextPage(
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
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    // report user button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: ReportUserButton(
                        firstName: user.user.firstName,
                        lastName: user.user.lastName,
                        onReportSubmitted: () {
                          // Logic after the report is submitted,
                          //such as showing a confirmation message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                              'Report submitted successfully',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.white),
                            )),
                          );
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
                        '${user.user.firstName} ${user.user.lastName}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        countdown != null
                            ? '$countdown...'
                            : 'Press & hold the logo to send a friend request',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
