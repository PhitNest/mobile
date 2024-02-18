import '../../entities/entities.dart';
import '../../util/http/http.dart';

Future<HttpResponse<Explore>> explore(Session session) => request(
      route: 'explore',
      method: HttpMethod.get,
      parse: Explore.fromJson,
      session: session,
    );
