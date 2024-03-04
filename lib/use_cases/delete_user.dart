import '../entities/session/session.dart';
import '../repositories/repositories.dart';
import '../util/http/http.dart';

/// Deletes the user from the API, then deletes the user's account from Cognito.
Future<HttpResponse<bool>> deleteUserAccount(Session session) =>
    deleteUser(session).then(
      (res) => res.handleAll(
        success: (_, headers) async =>
            HttpResponseSuccess(await deleteAccount(session), headers),
        failure: (failure, headers) => HttpResponseFailure(failure, headers),
      ),
    );
