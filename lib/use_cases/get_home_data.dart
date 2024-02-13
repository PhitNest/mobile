import '../entities/entities.dart';
import '../repositories/repositories.dart';
import '../repositories/s3/aws.dart';
import '../util/http/http.dart';

Future<HttpResponse<HomeDataPicturesLoaded>> getHomeData(
    Session session) async {
  switch (await homeData(session)) {
    case HttpResponseSuccess(data: final data, headers: final headers):
      final receivedRequestUserIds = <String, FriendRequest>{};
      final sentRequestUserIds = <String, FriendRequest>{};
      final friendUserIds = <String, FriendRequest>{};

      for (final friendRequest in data.friendRequests) {
        if (friendRequest.accepted) {
          friendUserIds.putIfAbsent(
              friendRequest.other(data.user.id).id, () => friendRequest);
        } else if (friendRequest.sender.id == data.user.id) {
          sentRequestUserIds.putIfAbsent(
              friendRequest.receiver.id, () => friendRequest);
        } else {
          receivedRequestUserIds.putIfAbsent(
              friendRequest.sender.id, () => friendRequest);
        }
      }

      final receivedRequests = <FriendRequestWithProfilePicture>[];
      final friends = <FriendRequestWithProfilePicture>[];

      final exploreUsers = (await Future.wait(data.explore
              .where((exploreUser) =>
                  exploreUser.id != data.user.id &&
                  !sentRequestUserIds.containsKey(exploreUser.id))
              .map((user) async {
        // TODO: FIX
        final profilePicture =
            await getProfilePicture(session as AwsSession, user.identityId);
        if (profilePicture != null) {
          if (friendUserIds.containsKey(user.id)) {
            final friendRequest = friendUserIds[user.id]!;
            friends.add(FriendRequestWithProfilePicture(
              accepted: friendRequest.accepted,
              createdAt: friendRequest.createdAt,
              receiver: friendRequest.receiver,
              sender: friendRequest.sender,
              profilePicture: profilePicture,
            ));
          } else {
            if (receivedRequestUserIds.containsKey(user.id)) {
              final friendRequest = receivedRequestUserIds[user.id]!;
              receivedRequests.add(FriendRequestWithProfilePicture(
                accepted: friendRequest.accepted,
                createdAt: friendRequest.createdAt,
                receiver: friendRequest.receiver,
                sender: friendRequest.sender,
                profilePicture: profilePicture,
              ));
            }
            return ExploreUser(
              id: user.id,
              firstName: user.firstName,
              lastName: user.lastName,
              identityId: user.identityId,
              profilePicture: profilePicture,
            );
          }
        }
        return null;
      })))
          .where((exploreUser) => exploreUser != null)
          .cast<ExploreUser>()
          .toList();
      // TODO: FIX
      final profilePicture =
          await getProfilePicture(session as AwsSession, data.user.identityId);

      return profilePicture != null
          ? HttpResponseOk(
              HomeDataLoaded(
                user: data.user,
                profilePicture: profilePicture,
                exploreUsers: exploreUsers,
                receivedFriendRequests: receivedRequests,
                friends: friends,
              ),
              headers,
            )
          : HttpResponseOk(
              FailedToLoadProfilePicture(
                user: data.user,
                receivedFriendRequests: receivedRequests,
                friends: friends,
                exploreUsers: exploreUsers,
              ),
              headers,
            );
    case HttpResponseFailure(failure: final failure, headers: final headers):
      return HttpResponseFailure(failure, headers);
  }
}
