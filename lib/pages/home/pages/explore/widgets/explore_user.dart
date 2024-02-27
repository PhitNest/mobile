import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../entities/entities.dart';
import '../../../../../repositories/repositories.dart';
import '../../../../../util/bloc/bloc.dart';
import '../../../../../util/http/http.dart';
import '../../../../../widgets/widgets.dart';
import '../../../home.dart';
import 'report_user.dart';

typedef ExploreProfilePictureBloc
    = AuthLoaderBloc<void, ({Uri uri, Map<String, String> headers})>;
typedef ExploreProfilePictureConsumer
    = AuthLoaderConsumer<void, ({Uri uri, Map<String, String> headers})>;

final class ExploreUserPage extends StatelessWidget {
  final User user;
  final int? countdown;
  final PageController pageController;
  final HomeResponse homeResponse;
  final Headers homeResponseHeaders;
  final bool loading;

  const ExploreUserPage({
    super.key,
    required this.user,
    required this.loading,
    required this.homeResponseHeaders,
    required this.countdown,
    required this.pageController,
    required this.homeResponse,
  }) : super();

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                height: 444,
                width: 375,
                child: BlocProvider(
                  create: (context) => ExploreProfilePictureBloc(
                    sessionLoader: context.sessionLoader,
                    load: (_, session) async =>
                        // TODO: FIX
                        getProfilePictureUri(
                            session as AwsSession, user.identityId),
                    loadOnStart: const LoadOnStart(null),
                  ),
                  child: ExploreProfilePictureConsumer(
                    listener: (context, profilePictureState) {},
                    builder: (context, profilePictureState) =>
                        profilePictureState.handleAuth(
                      success: (image) => Image.network(
                        image.uri.toString(),
                        headers: image.headers,
                        errorBuilder: (context, _, __) {
                          context.homeBloc.add(
                            LoaderSetEvent(
                              AuthRes(
                                HttpResponseOk(
                                  HomeResponse(
                                    user: homeResponse.user,
                                    explore: [...homeResponse.explore]
                                      ..remove(user),
                                    pendingRequests: [
                                      ...homeResponse.pendingRequests
                                    ]..removeWhere(
                                        (element) =>
                                            element
                                                .other(homeResponse.user.id)
                                                .id ==
                                            user.id,
                                      ),
                                    friends: [...homeResponse.friends]
                                      ..removeWhere(
                                        (element) =>
                                            element
                                                .other(homeResponse.user.id)
                                                .id ==
                                            user.id,
                                      ),
                                  ),
                                  homeResponseHeaders,
                                ),
                              ),
                            ),
                          );
                          return const Loader();
                        },
                      ),
                      fallback: () => const Loader(),
                    ),
                  ),
                ),
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
              if (!loading)
                Positioned(
                  top: 16,
                  right: 16,
                  child: ReportUserButton(
                    firstName: user.firstName,
                    lastName: user.lastName,
                    onReportSubmitted: () {
                      StyledBanner.show(
                        message: 'Report submitted successfully',
                        error: false,
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
                  user.fullName,
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
      );
}
