import 'package:flutter/material.dart';

import '../entities/entities.dart';
import '../repositories/repositories.dart';
import '../util/http/http.dart';

ExploreProfilePictures exploreProfilePictures(
        Session session, List<User> explore) =>
    ExploreProfilePictures(
        explore: explore.map((e) {
      // TODO: FIX
      final profilePictureUri =
          getProfilePictureUri(session as AwsSession, e.identityId);
      return ExploreUser(
        id: e.id,
        firstName: e.firstName,
        lastName: e.lastName,
        identityId: e.identityId,
        profilePicture: Image.network(
          profilePictureUri.uri.toString(),
          headers: profilePictureUri.headers,
        ),
      );
    }).toList());

Future<HttpResponse<ExploreProfilePictures>> exploreWithProfilePictures(
        Session session) =>
    explore(session).then((response) => switch (response) {
          HttpResponseSuccess(data: final data, headers: final headers) =>
            HttpResponseOk(
              exploreProfilePictures(
                session,
                data.explore,
              ),
              headers,
            ),
          HttpResponseFailure(failure: final failure, headers: final headers) =>
            HttpResponseFailure(failure, headers),
        });

Future<HttpResponse<HomeResponseWithProfilePictures>>
    homeDataWithProfilePictures(Session session) async {
  switch (await homeData(session)) {
    case HttpResponseSuccess(data: final data, headers: final headers):
      // TODO: FIX
      final userProfilePicture =
          await getProfilePicture(session as AwsSession, data.user.identityId);

      final exploreUsers = exploreProfilePictures(session, data.explore);

      final sentRequests = data.sentRequests.map(
        (e) {
          final profilePictureUri =
              getProfilePictureUri(session, e.receiver.id);
          return FriendRequestWithProfilePicture(
            sender: e.sender,
            receiver: e.receiver,
            accepted: e.accepted,
            profilePicture: Image.network(
              profilePictureUri.uri.toString(),
              headers: profilePictureUri.headers,
            ),
            createdAt: e.createdAt,
          );
        },
      ).toList();

      final receivedRequests = data.receivedRequests.map(
        (e) {
          final profilePictureUri = getProfilePictureUri(session, e.sender.id);
          return FriendRequestWithProfilePicture(
            sender: e.sender,
            receiver: e.receiver,
            accepted: e.accepted,
            profilePicture: Image.network(
              profilePictureUri.uri.toString(),
              headers: profilePictureUri.headers,
            ),
            createdAt: e.createdAt,
          );
        },
      ).toList();

      return HttpResponseOk(
        HomeResponseWithProfilePictures(
          user: UserWithEmail(
            id: data.user.id,
            firstName: data.user.firstName,
            lastName: data.user.lastName,
            identityId: data.user.identityId,
            email: data.user.email,
          ),
          explore: exploreUsers.explore,
          profilePicture: userProfilePicture,
          sentRequests: sentRequests,
          receivedRequests: receivedRequests,
        ),
        headers,
      );
    case HttpResponseFailure(failure: final failure, headers: final headers):
      return HttpResponseFailure(failure, headers);
  }
}
