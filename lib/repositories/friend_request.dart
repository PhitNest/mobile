import '../entities/friend_request.dart';
import '../entities/session/session.dart';
import '../util/http/http.dart';

Future<HttpResponse<FriendRequest>> sendFriendRequest(
  String receiverId,
  Session session,
) =>
    request(
      route: 'friend-request',
      method: HttpMethod.post,
      session: session,
      data: {
        'receiverId': receiverId,
      },
      parse: FriendRequest.fromJson,
    );

Future<HttpResponse<void>> deleteFriendRequest(
  String friendRequestSenderId,
  String friendRequestReceiverId,
  Session session,
) =>
    request(
      route: 'friend-request',
      method: HttpMethod.delete,
      session: session,
      data: {
        'friendRequestSenderId': friendRequestSenderId,
        'friendRequestReceiverId': friendRequestReceiverId,
      },
      parse: (_) {},
    );
