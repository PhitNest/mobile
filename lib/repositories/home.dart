import '../entities/entities.dart';
import '../util/http/http.dart';

Future<HttpResponse<HomeData>> homeData(Session session) => request(
      route: 'home',
      method: HttpMethod.get,
      parse: HomeData.fromJson,
      session: session,
    );
