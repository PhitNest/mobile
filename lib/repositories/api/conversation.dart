import '../../entities/entities.dart';
import '../../util/http/http.dart';

Future<HttpResponse<Conversation>> conversation(
  String friendRequestSenderId,
  String friendRequestReceiverId,
  Session session,
) =>
    request(
      route: 'conversation',
      method: HttpMethod.get,
      session: session,
      data: {
        'friendRequestSenderId': friendRequestSenderId,
        'friendRequestReceiverId': friendRequestReceiverId,
      },
      parse: Conversation.fromJson,
    );
