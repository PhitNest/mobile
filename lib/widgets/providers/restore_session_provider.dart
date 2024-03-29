import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entities/entities.dart';
import '../../repositories/cognito/cognito.dart';
import '../../util/bloc/bloc.dart';
import '../styled_loader.dart';

typedef RestorePreviousSessionBloc = LoaderBloc<void, RefreshSessionResponse>;
typedef RestorePreviousSessionConsumer
    = LoaderConsumer<void, RefreshSessionResponse>;

final class RestorePreviousSessionProvider extends StatelessWidget {
  final void Function(BuildContext context, Session session) onSessionRestored;
  final void Function(BuildContext context) onSessionRestoreFailed;

  const RestorePreviousSessionProvider({
    super.key,
    required this.onSessionRestored,
    required this.onSessionRestoreFailed,
  }) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => RestorePreviousSessionBloc(
          load: (_) => getPreviousSession(),
          loadOnStart: const LoadOnStart(null),
        ),
        child: RestorePreviousSessionConsumer(
          listener: (context, restoreSessionState) =>
              restoreSessionState.handle(
            loaded: (response) => switch (response) {
              RefreshSessionFailureResponse() =>
                onSessionRestoreFailed(context),
              RefreshSessionSuccess(session: final session) =>
                onSessionRestored(context, session),
            },
            fallback: () {},
          ),
          builder: (context, restoreSessionState) => const Loader(),
        ),
      );
}
