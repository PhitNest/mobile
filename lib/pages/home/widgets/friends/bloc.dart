part of 'friends.dart';

typedef DeleteFriendRequestBloc = AuthParallelLoaderBloc<
    FriendRequestWithProfilePicture, HttpResponse<void>>;
typedef DeleteFriendRequestConsumer = AuthParallelLoaderConsumer<
    FriendRequestWithProfilePicture, HttpResponse<void>>;

final class FriendsPageState extends Equatable {
  final List<FriendRequestWithProfilePicture> friends;
  final List<FriendRequestWithProfilePicture> requests;
  final List<ExploreUser> exploreUsers;

  const FriendsPageState({
    required this.friends,
    required this.requests,
    required this.exploreUsers,
  }) : super();

  @override
  List<Object?> get props => [friends, requests, exploreUsers];
}

sealed class FriendsPageEvent extends Equatable {
  const FriendsPageEvent() : super();
}

final class FriendAddedEvent extends FriendsPageEvent {
  final FriendRequestWithProfilePicture friend;

  const FriendAddedEvent(this.friend) : super();

  @override
  List<Object?> get props => [friend];
}

final class FriendRemovedEvent extends FriendsPageEvent {
  final FriendRequestWithProfilePicture friend;

  const FriendRemovedEvent(this.friend) : super();

  @override
  List<Object?> get props => [friend];
}

final class FriendRequestDeniedEvent extends FriendsPageEvent {
  final FriendRequestWithProfilePicture request;

  const FriendRequestDeniedEvent(this.request) : super();

  @override
  List<Object?> get props => [request];
}

void _handleFriendRequestPageStateChanged(
  BuildContext context,
  FriendsPageState state,
) {}

final class FriendRequestPageBloc
    extends Bloc<FriendsPageEvent, FriendsPageState> {
  FriendRequestPageBloc({
    required String userId,
    required List<FriendRequestWithProfilePicture> initialFriends,
    required List<FriendRequestWithProfilePicture> initialReceivedRequests,
    required List<ExploreUser> initialExploreUsers,
  }) : super(FriendsPageState(
          friends: initialFriends,
          requests: initialReceivedRequests,
          exploreUsers: initialExploreUsers,
        )) {
    on<FriendAddedEvent>(
      (event, emit) {
        emit(FriendsPageState(
          friends: state.friends..add(event.friend),
          requests: state.requests
            ..removeWhere(
              (request) =>
                  request.friendRequest.sender.id ==
                  event.friend.friendRequest.sender.id,
            ),
          exploreUsers: state.exploreUsers
            ..removeWhere(
              (user) => user.user.id == event.friend.friendRequest.sender.id,
            ),
        ));
      },
    );

    on<FriendRemovedEvent>(
      (event, emit) {
        emit(FriendsPageState(
            friends: state.friends..remove(event.friend),
            requests: state.requests,
            exploreUsers: state.exploreUsers
              ..add(ExploreUser(
                user: event.friend.friendRequest.other(userId),
                profilePicture: event.friend.profilePicture,
              ))));
      },
    );

    on<FriendRequestDeniedEvent>(
      (event, emit) {
        emit(
          FriendsPageState(
            friends: state.friends,
            requests: state.requests..remove(event.request),
            exploreUsers: state.exploreUsers,
          ),
        );
      },
    );
  }
}

typedef FriendRequestPageConsumer
    = BlocConsumer<FriendRequestPageBloc, FriendsPageState>;

extension on BuildContext {
  FriendRequestPageBloc get friendRequestPageBloc =>
      BlocProvider.of<FriendRequestPageBloc>(this);
  DeleteFriendRequestBloc get deleteFriendshipBloc => authParallelBloc();
}

void _handleSendFriendRequestStateChanged(
  BuildContext context,
  ParallelLoaderState<ExploreUser, AuthResOrLost<HttpResponse<FriendRequest>>>
      loaderState,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response, req: final req):
      switch (response) {
        case AuthRes(data: final response):
          switch (response) {
            case HttpResponseSuccess(data: final response):
              StyledBanner.show(
                message: 'Friend added',
                error: false,
              );
              context.friendRequestPageBloc
                  .add(FriendAddedEvent(FriendRequestWithProfilePicture(
                friendRequest: response,
                profilePicture: req.profilePicture,
              )));
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(
                message: failure.message,
                error: true,
              );
          }
        case AuthLost(message: final message):
          StyledBanner.show(
            message: message,
            error: true,
          );
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (_) => const LoginPage(),
            ),
            (_) => false,
          );
      }
  }
}

void _handleDeleteFriendshipStateChanged(
  BuildContext context,
  ParallelLoaderState<FriendRequestWithProfilePicture,
          AuthResOrLost<HttpResponse<void>>>
      loaderState,
) {
  switch (loaderState) {
    case ParallelLoadedState(data: final response, req: final req):
      switch (response) {
        case AuthRes(data: final response):
          switch (response) {
            case HttpResponseSuccess():
              if (req.friendRequest.accepted) {
                StyledBanner.show(
                  message: 'Friend removed',
                  error: false,
                );
                context.friendRequestPageBloc.add(FriendRemovedEvent(req));
              }
            case HttpResponseFailure(failure: final failure):
              StyledBanner.show(
                message: failure.message,
                error: true,
              );
          }
        case AuthLost(message: final message):
          StyledBanner.show(
            message: message,
            error: true,
          );
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (_) => const LoginPage(),
            ),
            (_) => false,
          );
      }
  }
}
