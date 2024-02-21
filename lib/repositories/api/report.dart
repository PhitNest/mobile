import '../../entities/entities.dart';
import '../../util/http/http.dart';

Future<HttpResponse<void>> sendReport(
  Session session,
  String receiverId,
  String reason,
) =>
    request(
      route: 'report',
      method: HttpMethod.post,
      session: session,
      data: {
        'receiverId': receiverId,
        'reason': reason,
      },
      parse: (_) {},
    );
