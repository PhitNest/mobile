import '../entities/entities.dart';
import '../util/aws/session.dart';
import '../util/http/http.dart';

Future<HttpResponse<GetUserResponse>> getUser(Session session) => request(
      route: 'user',
      method: HttpMethod.get,
      parse: (json) => GetUserResponse.parse(json as Map<String, dynamic>),
      session: session,
    );

Future<HttpResponse<void>> deleteUser(Session session) => request(
      route: 'user',
      method: HttpMethod.delete,
      parse: (_) {},
      session: session,
    );
