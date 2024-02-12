import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../entities/entities.dart';
import '../../../../use_cases/explore_data.dart';
import '../../../../util/bloc/bloc.dart';
import '../../../../util/http/http.dart';
import '../../../../widgets/styled_loader.dart';
import '../navbar/navbar.dart';
import 'widgets/blocs/explore_user_cubit.dart';
import 'widgets/widgets.dart';

class ExplorePage extends StatelessWidget {
  final PageController pageController;
  final NavBarState navBarState;
  static const PageStorageKey<String> pageStorageKey =
      PageStorageKey('explore');

  static Widget create(
      {required PageController pageController,
      required List<ExploreUser> users,
      required NavBarState navBarState}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => ExploreBloc(
                sessionLoader: context.sessionLoader,
                load: (_, session) => getExploreData(session),
                initialData: AuthRes(
                    HttpResponseOk(ExploreDataModel.manual(users), null))))
      ],
      child:
          ExplorePage(pageController: pageController, navBarState: navBarState),
    );
  }

  const ExplorePage({
    super.key,
    required this.pageController,
    required this.navBarState,
  }) : super();

  @override
  Widget build(BuildContext context) => ExploreConsumer(
        builder: (context, state) {
          switch (state) {
            case LoaderInitialState():
              return const Loader();
            case LoaderLoadedState(data: final response):
              return _authCheck(context, response);
            case LoaderInitialLoadingState():
              return const Loader();
            case LoaderRefreshingState():
              return const Loader();
          }
        },
        listener: (context, state) {},
      );

  Widget _authCheck(BuildContext context,
      AuthResOrLost<HttpResponse<ExploreDataModel>> data) {
    switch (data) {
      case AuthRes(data: final response):
        return _responseCheck(context, response);
      case AuthLost():
        return const ExploreEmptyPageRefresher();
    }
  }

  Widget _responseCheck(
      BuildContext context, HttpResponse<ExploreDataModel> data) {
    switch (data) {
      case HttpResponseFailure():
        return const ExploreEmptyPageRefresher();
      case HttpResponseOk(data: final response):
        return _exploreContent(context, response);
      case HttpResponseCache(data: final response):
        return _exploreContent(context, response);
    }
  }

  Widget _exploreContent(BuildContext context, ExploreDataModel data) {
    if (data.users.isEmpty) {
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
          user: data.users.toList()[page % data.users.length],
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
    return InkWell(
        child: const EmptyPage(),
        onTap: () => BlocProvider.of<ExploreBloc>(context).add(
              const LoaderLoadEvent(null),
            ));
  }
}
