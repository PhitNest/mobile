import 'package:equatable/equatable.dart';

import '../../session/session.dart';
import 'constants.dart';

sealed class RefreshSessionResponse extends Equatable {
  const RefreshSessionResponse();
}

final class RefreshSessionSuccess extends RefreshSessionResponse {
  final Session session;

  const RefreshSessionSuccess(this.session) : super();

  @override
  List<Object?> get props => [session];
}

sealed class RefreshSessionFailureResponse extends RefreshSessionResponse {
  String get message;

  const RefreshSessionFailureResponse() : super();
}

final class SessionEnded extends RefreshSessionFailureResponse {
  @override
  String get message => 'You have been logged out.';

  const SessionEnded() : super();

  @override
  List<Object?> get props => [];
}

enum RefreshSessionFailureType {
  invalidUserPool,
  noSuchUser,
  invalidToken;

  String get message => switch (this) {
        RefreshSessionFailureType.invalidUserPool => kInvalidUserPool,
        RefreshSessionFailureType.noSuchUser => kNoSuchUser,
        RefreshSessionFailureType.invalidToken => 'Invalid token.'
      };
}

final class RefreshSessionKnownFailure extends RefreshSessionFailureResponse {
  @override
  String get message => type.message;

  final RefreshSessionFailureType type;

  const RefreshSessionKnownFailure(this.type) : super();

  @override
  List<Object?> get props => [type];
}

final class RefreshSessionUnknownFailure extends RefreshSessionFailureResponse {
  @override
  final String message;

  const RefreshSessionUnknownFailure({
    required String? message,
  })  : message = message ?? kUnknownError,
        super();

  @override
  List<Object?> get props => [message];
}
