import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/aws/aws.dart';
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
          listener: (context, restoreSessionState) {
            switch (restoreSessionState) {
              case LoaderLoadedState(data: final restoreSessionResponse):
                switch (restoreSessionResponse) {
                  case RefreshSessionFailureResponse():
                    onSessionRestoreFailed(context);
                  case RefreshSessionSuccess(session: final session):
                    onSessionRestored(context, session);
                }
              default:
            }
          },
          builder: (context, restoreSessionState) => const Loader(),
        ),
      );
}
