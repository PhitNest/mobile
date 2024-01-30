import '../entities/entities.dart';
import '../util/aws/session.dart';
import '../util/http/http.dart';

Future<HttpResponse<HomeData>> homeData(Session session) => request(
      route: 'home',
      method: HttpMethod.get,
      parse: (json) => HomeData.parse(json as Map<String, dynamic>),
      session: session,
    );
