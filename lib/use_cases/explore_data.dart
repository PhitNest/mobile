import '../entities/explore_data_model.dart';
import '../entities/session/session.dart';
import '../entities/user.dart';
import '../repositories/explore.dart';
import '../repositories/s3/aws.dart';
import '../util/http/http.dart';

Future<HttpResponse<ExploreDataLoaded>> getExploreData(
    Session session,
    String userId,
    Set<String> friendUserIds,
    Set<String> sentRequestUserIds) async {
  switch (await exploreData(session)) {
    case HttpResponseSuccess(data: final data, headers: final headers):
      final exploreUsers = (await Future.wait(data.explore
              .where((exploreUser) =>
                  exploreUser.id != userId &&
                  !sentRequestUserIds.contains(exploreUser.id))
              .map((user) async {
        final profilePicture =
            await getProfilePicture(session as AwsSession, user.identityId);
        if (profilePicture != null) {
          if (!friendUserIds.contains(user.id)) {
            return ExploreUser(
              user: user,
              profilePicture: profilePicture,
            );
          }
        }
        return null;
      })))
          .where((exploreUser) => exploreUser != null)
          .cast<ExploreUser>()
          .toList();
      return HttpResponseOk(
          ExploreDataLoaded(exploreUsers: exploreUsers), headers);
    case HttpResponseFailure(failure: final failure, headers: final headers):
      return HttpResponseFailure(failure, headers);
  }
}
