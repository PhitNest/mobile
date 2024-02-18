import '../../entities/entities.dart';
import '../../util/http/http.dart';

Future<HttpResponse<HomeResponse>> homeData(Session session) => request(
      route: 'home',
      method: HttpMethod.get,
      parse: HomeResponse.fromJson,
      session: session,
    );
