import '../entities/explore_data_model.dart';
import '../entities/session/session.dart';
import '../util/http/http.dart';

Future<HttpResponse<ExploreDataModel>> exploreData(Session session) => request(
      route: 'explore',
      method: HttpMethod.get,
      parse: (json) => ExploreDataModel.parse(json as Map<String, dynamic>),
      session: session,
    );
