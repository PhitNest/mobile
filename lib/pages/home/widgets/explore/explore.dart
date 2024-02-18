import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../entities/api/api.dart';
import '../../../../entities/entities.dart';
import '../../../../use_cases/profile_pictures.dart';
import '../../../../util/bloc/bloc.dart';
import '../../../../util/http/http.dart';
import '../../../../widgets/widgets.dart';
import '../../../pages.dart';
import '../navbar/navbar.dart';
import 'widgets/widgets.dart';

part 'bloc.dart';

class ExplorePage extends StatelessWidget {
  final PageController pageController;
  final NavBarState navBarState;
  final HomeResponseWithProfilePictures homeResponse;
  static const PageStorageKey<String> pageStorageKey =
      PageStorageKey('explore');

  const ExplorePage({
    super.key,
    required this.homeResponse,
    required this.pageController,
    required this.navBarState,
  }) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => ExploreBloc(
          sessionLoader: context.sessionLoader,
          load: (_, session) => exploreWithProfilePictures(session),
          initialData: AuthRes(HttpResponseOk(
              ExploreProfilePictures(explore: homeResponse.explore), null)),
        ),
        child: ExploreConsumer(
          builder: (context, state) => switch (state) {
            LoaderInitialState() => const Loader(),
            LoaderLoadedState(data: final response) =>
              _authCheck(context, response),
            LoaderInitialLoadingState() => const Loader(),
            LoaderRefreshingState() => const Loader(),
          },
          listener: (context, state) =>
              _handleExploreStateChanged(context, homeResponse, state),
        ),
      );

  Widget _authCheck(BuildContext context,
      AuthResOrLost<HttpResponse<ExploreProfilePictures>> data) {
    switch (data) {
      case AuthRes(data: final response):
        return _responseCheck(context, response);
      case AuthLost():
        return const ExploreEmptyPageRefresher();
    }
  }

  Widget _responseCheck(
      BuildContext context, HttpResponse<ExploreProfilePictures> data) {
    switch (data) {
      case HttpResponseFailure():
        return const ExploreEmptyPageRefresher();
      case HttpResponseOk(data: final response):
        return _exploreContent(context, response);
      case HttpResponseCache(data: final response):
        return _exploreContent(context, response);
    }
  }

  Widget _exploreContent(BuildContext context, ExploreProfilePictures data) {
    if (data.explore.isEmpty) {
      return const ExploreEmptyPageRefresher();
    } else {
      return PageView.builder(
        key: pageStorageKey,
        controller: pageController,
        itemBuilder: (context, page) => ExploreUserPage(
          countdown: switch (navBarState) {
            NavBarHoldingLogoState(countdown: final countdown) => countdown,
            _ => null,
          },
          user: data.explore[page % data.explore.length],
          pageController: pageController,
        ),
      );
    }
  }
}

class ExploreEmptyPageRefresher extends StatelessWidget {
  const ExploreEmptyPageRefresher({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: Stack(
          children: [
            /// this is a trick to make the refresh indicator work for a single
            /// not scrollable widget child
            ListView(),
            const EmptyPage(),
          ],
        ),
        onRefresh: () => Future(() => context.exploreBloc.add(
              const LoaderLoadEvent(null),
            )));
  }
}
