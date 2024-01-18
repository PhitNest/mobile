import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'pages/pages.dart';
import 'theme.dart';
import 'util/aws/aws.dart';
import 'util/bloc/bloc.dart';
import 'util/cache/cache.dart';
import 'util/logger.dart';
import 'widgets/widgets.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeCache();
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://6ea76c391eb3687b5be5b29820bac0fb@o4506590032101376.ingest.sentry.io/4506590033149952';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
        PhitNestApp(Timer(const Duration(minutes: 1), () => logToSentry()))),
  );
}

final class PhitNestApp extends StatelessWidget {
  final Timer logger;

  const PhitNestApp(this.logger, {super.key}) : super();

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => SessionBloc(load: refreshSession),
        child: GestureDetector(
          onTap: () {
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: MaterialApp(
            title: 'PhitNest',
            theme: theme,
            scrollBehavior: AppScrollBehavior(),
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: StyledBanner.scaffoldMessengerKey,
            home: Scaffold(
              body: RestorePreviousSessionProvider(
                onSessionRestoreFailed: (context) =>
                    Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute<void>(
                    builder: (_) => const LoginPage(),
                  ),
                  (_) => false,
                ),
                onSessionRestored: (context, session) =>
                    Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute<void>(
                    builder: (_) => const HomePage(),
                  ),
                  (_) => false,
                ),
              ),
            ),
          ),
        ),
      );
}
