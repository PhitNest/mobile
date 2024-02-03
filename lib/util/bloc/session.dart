import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../aws/aws.dart';
import 'loader/loader.dart';
import 'parallel_loader/parallel_loader.dart';

/// Base class for session bloc data.
sealed class AuthResOrLost<ResType> extends Equatable {
  const AuthResOrLost() : super();
}

/// Use this class to indicate the session is valid and carries a data payload.
final class AuthRes<ResType> extends AuthResOrLost<ResType> {
  final ResType data;

  const AuthRes(this.data) : super();

  @override
  List<Object?> get props => [data];
}

/// Use this class to indicate the session is invalid and carries a message.
final class AuthLost<ResType> extends AuthResOrLost<ResType> {
  final String message;

  const AuthLost(this.message) : super();

  @override
  List<Object?> get props => [message];
}

/// Refreshes the session as needed and processes an async action that requires
/// a valid session.
Future<AuthResOrLost<ResType>> _handleRequest<ReqType, ResType>(
  Future<ResType> Function(ReqType, Session) load,
  SessionBloc sessionLoader,
  ReqType req,
) async {
  /// Returns either an auth lost error if the session is invalid or runs the
  /// `load` function with the valid session.
  Future<AuthResOrLost<ResType>> handleRefreshSessionResponse(
    RefreshSessionResponse refreshSessionResponse,
  ) async =>
      switch (refreshSessionResponse) {
        RefreshSessionSuccess(session: final session) =>
          AuthRes(await load(req, session)),
        RefreshSessionFailureResponse(message: final message) =>
          AuthLost(message),
      };

  switch (sessionLoader.state) {
    case LoaderLoadedState(data: final response):
      switch (response) {
        case RefreshSessionSuccess(session: final session):
          if (session.cognitoSession.isValid()) {
            return AuthRes(await load(req, session));
          } else {
            // Capture the next loaded state from the session loader.
            final nextResponse = sessionLoader.stream
                .where((event) => switch (event) {
                      LoaderLoadedState() => true,
                      _ => false,
                    })
                .cast<LoaderLoadedState<RefreshSessionResponse>>()
                .first;

            // Refresh the session.
            sessionLoader.add(LoaderLoadEvent(session));

            // Wait for the next loaded state from the session loader, and
            // handle it.
            return await handleRefreshSessionResponse(
                (await nextResponse).data);
          }
        default:
      }
    case LoaderLoadingState(operation: final operation):
      // Capture the next loaded state from the session loader.
      final response = await operation.valueOrCancellation();
      if (response == null) {
        return const AuthLost('Operation canceled');
      }
      return await handleRefreshSessionResponse(response);
    default:
  }
  // Try to restore the session from local storage.
  final response = await getPreviousSession();
  sessionLoader.add(LoaderSetEvent(response));
  switch (response) {
    case RefreshSessionSuccess(session: final session):
      if (session.cognitoSession.isValid()) {
        return AuthRes(await load(req, session));
      }
      return const AuthLost('No session found');
    case RefreshSessionFailureResponse(message: final message):
      return AuthLost(message);
  }
}

/// A bloc that refreshes the session as needed.
typedef SessionBloc = LoaderBloc<Session, RefreshSessionResponse>;

/// A bloc that refreshes the session as needed and processes an async action
/// with the valid session.
final class AuthLoaderBloc<ReqType, ResType>
    extends LoaderBloc<ReqType, AuthResOrLost<ResType>> {
  final SessionBloc sessionLoader;

  AuthLoaderBloc({
    required this.sessionLoader,
    required Future<ResType> Function(ReqType, Session) load,
    super.loadOnStart,
    super.initialData,
    super.onDispose,
  }) : super(load: (req) => _handleRequest(load, sessionLoader, req));
}

typedef AuthLoaderConsumer<ReqType, ResType> = BlocConsumer<
    AuthLoaderBloc<ReqType, ResType>, LoaderState<AuthResOrLost<ResType>>>;

/// A bloc that refreshes the session as needed and processes multiple async
/// actions with the valid session.
final class AuthParallelLoaderBloc<ReqType, ResType>
    extends ParallelLoaderBloc<ReqType, AuthResOrLost<ResType>> {
  final SessionBloc sessionLoader;

  AuthParallelLoaderBloc({
    required this.sessionLoader,
    required Future<ResType> Function(ReqType, Session) load,
  }) : super(load: (req) => _handleRequest(load, sessionLoader, req));
}

typedef AuthParallelLoaderConsumer<ReqType, ResType> = BlocConsumer<
    AuthParallelLoaderBloc<ReqType, ResType>,
    ParallelLoaderState<ReqType, AuthResOrLost<ResType>>>;

extension AuthLoaders on BuildContext {
  AuthLoaderBloc<ReqType, ResType> authLoader<ReqType, ResType>() =>
      BlocProvider.of(this);

  AuthParallelLoaderBloc<ReqType, ResType>
      authParallelBloc<ReqType, ResType>() => BlocProvider.of(this);

  SessionBloc get sessionLoader => loader();
}
