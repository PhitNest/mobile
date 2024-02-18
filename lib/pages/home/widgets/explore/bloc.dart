part of 'explore.dart';

typedef ExploreBloc
    = AuthLoaderBloc<void, HttpResponse<ExploreProfilePictures>>;
typedef ExploreConsumer
    = AuthLoaderConsumer<void, HttpResponse<ExploreProfilePictures>>;

extension ExploreBlocGetter on BuildContext {
  ExploreBloc get exploreBloc => authLoader();
}

void _handleExploreStateChanged(
  BuildContext context,
  final HomeResponseWithProfilePictures homeResponse,
  LoaderState<AuthResOrLost<HttpResponse<ExploreProfilePictures>>> loaderState,
) {
  switch (loaderState) {
    case LoaderLoadedState(data: final response):
      switch (response) {
        case AuthRes(data: final response):
          switch (response) {
            case HttpResponseSuccess(data: final data, headers: final headers):
              context.homeBloc.add(LoaderSetEvent(AuthRes(HttpResponseOk(
                  HomeResponseWithProfilePictures(
                    explore: data.explore,
                    profilePicture: homeResponse.profilePicture,
                    user: homeResponse.user,
                    receivedRequests: homeResponse.receivedRequests,
                    sentRequests: homeResponse.sentRequests,
                  ),
                  headers))));
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(message: failure.message, error: true);
          }
        default:
      }
    default:
  }
}
