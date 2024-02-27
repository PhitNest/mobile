import '../../entities/entities.dart';
import '../../util/http/http.dart';

Future<HttpResponse<HomeResponse>> homeData(Session session) => request(
      route: 'home',
      method: HttpMethod.get,
      parse: HomeResponse.fromJson,
      data: {'version': '1.0.0'},
      session: session,
    );
