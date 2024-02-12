import '../entities/explore_data_model.dart';
import '../entities/session/session.dart';
import '../repositories/explore.dart';
import '../util/http/http.dart';

Future<HttpResponse<ExploreDataModel>> getExploreData(Session session) async {
  switch (await exploreData(session)) {
    case HttpResponseSuccess(data: final data, headers: final headers):
      return HttpResponseOk(data, headers);
    case HttpResponseFailure(failure: final failure, headers: final headers):
      return HttpResponseFailure(failure, headers);
  }
}
