import '../entities/session/session.dart';
import '../repositories/repositories.dart';
import '../util/http/http.dart';

/// Deletes the user from the API, then deletes the user's account from Cognito.
Future<HttpResponse<bool>> deleteUserAccount(Session session) =>
    deleteUser(session).then(
      (res) async => switch (res) {
        HttpResponseSuccess(headers: final headers) =>
          HttpResponseOk(await deleteAccount(session), headers),
        HttpResponseFailure(failure: final failure, headers: final headers) =>
          HttpResponseFailure(failure, headers),
      },
    );
