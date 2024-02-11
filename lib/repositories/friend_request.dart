import '../entities/friend_request.dart';
import '../entities/session.dart';
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
      parse: (json) => FriendRequest.parse(json as Map<String, dynamic>),
    );

Future<HttpResponse<void>> deleteFriendRequest(
  String receiverId,
  Session session,
) =>
    request(
      route: 'friend-request',
      method: HttpMethod.delete,
      session: session,
      data: {
        'friendId': receiverId,
      },
      parse: (_) {},
    );
