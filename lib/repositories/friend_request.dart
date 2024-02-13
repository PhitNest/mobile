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
