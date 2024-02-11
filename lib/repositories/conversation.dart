import '../entities/entities.dart';
import '../util/http/http.dart';

Future<HttpResponse<Conversation>> conversation(
  String friendId,
  Session session,
) =>
    request(
      route: 'conversation',
      method: HttpMethod.get,
      session: session,
      data: {
        'friendId': friendId,
      },
      parse: (json) => Conversation.parse(json as Map<String, dynamic>),
    );
