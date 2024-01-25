import '../util/aws/session.dart';
import '../util/http/http.dart';

Future<HttpResponse<void>> deleteUser(Session session) => request(
      route: 'user',
      method: HttpMethod.delete,
      parse: (_) {},
      session: session,
    );
