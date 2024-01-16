import '../entities/entities.dart';
import '../repositories/repositories.dart';
import '../util/aws/aws.dart';
import '../util/http/http.dart';

Future<HttpResponse<GetUserResponseWithExplorePictures>> user(
    Session session) async {
  switch (await getUser(session)) {
    case HttpResponseSuccess(data: final data, headers: final headers):
      final receivedUserIds = <String, FriendRequest>{};
      final sentRequestUserIds = <String, FriendRequest>{};
      final friendUserIds = <String, FriendRequest>{};

      for (final friendRequest in data.friendRequests) {
        if (friendRequest.accepted) {
          friendUserIds.putIfAbsent(
              friendRequest.sender.id == data.user.id
                  ? friendRequest.receiver.id
                  : friendRequest.sender.id,
              () => friendRequest);
        } else if (friendRequest.sender.id == data.user.id) {
          sentRequestUserIds.putIfAbsent(
              friendRequest.receiver.id, () => friendRequest);
        } else {
          receivedUserIds.putIfAbsent(
              friendRequest.sender.id, () => friendRequest);
        }
      }

      final List<FriendRequestWithProfilePicture> receivedRequests = [];
      final List<FriendRequestWithProfilePicture> sentRequests = [];
      final List<FriendRequestWithProfilePicture> friends = [];

      final exploreUsers = (await Future.wait(data.explore.map((user) async {
        final profilePicture =
            await getProfilePicture(session, user.identityId);
        if (profilePicture != null) {
          if (sentRequestUserIds.containsKey(user.id)) {
            sentRequests.add(FriendRequestWithProfilePicture(
              friendRequest: sentRequestUserIds[user.id]!,
              profilePicture: profilePicture,
            ));
          } else if (friendUserIds.containsKey(user.id)) {
            friends.add(FriendRequestWithProfilePicture(
              friendRequest: friendUserIds[user.id]!,
              profilePicture: profilePicture,
            ));
          } else {
            if (receivedUserIds.containsKey(user.id)) {
              receivedRequests.add(FriendRequestWithProfilePicture(
                friendRequest: receivedUserIds[user.id]!,
                profilePicture: profilePicture,
              ));
            }
            return ExploreUser(
              user: user,
              profilePicture: profilePicture,
            );
          }
        }
        return null;
      })))
          .where((exploreUser) =>
              exploreUser != null && exploreUser.user.id != data.user.id)
          .cast<ExploreUser>()
          .toList();

      final profilePicture =
          await getProfilePicture(session, data.user.identityId);
      if (profilePicture == null) {
        return HttpResponseOk(
          FailedToLoadProfilePicture(
            user: data.user,
            sentFriendRequests: sentRequests,
            receivedFriendRequests: receivedRequests,
            friends: friends,
            exploreUsers: exploreUsers,
          ),
          headers,
        );
      }
      return HttpResponseOk(
        GetUserSuccess(
          user: data.user,
          profilePicture: profilePicture,
          exploreUsers: exploreUsers,
          sentFriendRequests: sentRequests,
          receivedFriendRequests: receivedRequests,
          friends: friends,
        ),
        headers,
      );
    case HttpResponseFailure(failure: final failure, headers: final headers):
      return HttpResponseFailure(failure, headers);
  }
}
