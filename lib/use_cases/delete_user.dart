import '../entities/session.dart';
import '../repositories/cognito/cognito.dart';
import '../repositories/repositories.dart';
import '../util/http/http.dart';

Future<HttpResponse<bool>> deleteUserAccount(Session session) =>
    deleteUser(session).then(
      (res) async => switch (res) {
        HttpResponseSuccess(headers: final headers) => HttpResponseOk(
            await Cognito.instance.deleteAccount(session), headers),
        HttpResponseFailure(failure: final failure, headers: final headers) =>
          HttpResponseFailure(failure, headers),
      },
    );
