import '../repositories/repositories.dart';
import '../util/aws/aws.dart';
import '../util/http/http.dart';

Future<HttpResponse<bool>> deleteUserAccount(Session session) =>
    deleteUser(session).then(
      (res) async => switch (res) {
        HttpResponseSuccess(headers: final headers) =>
          HttpResponseOk(await deleteAccount(session), headers),
        HttpResponseFailure(failure: final failure, headers: final headers) =>
          HttpResponseFailure(failure, headers),
      },
    );
