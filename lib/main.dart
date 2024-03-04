import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'pages/pages.dart';
import 'theme.dart';
import 'util/bloc/bloc.dart';
import 'util/cache/cache.dart';
import 'widgets/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeCache();
  runApp(const PhitNestApp());
}

class _ScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

final class PhitNestApp extends StatelessWidget {
  const PhitNestApp({super.key}) : super();

  @override
  Widget build(BuildContext context) =>
      // Provides the session bloc to the entire app
      BlocProvider(
        create: sessionBloc,
        // Unfocuses the keyboard when the user taps outside of a text field
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
            scrollBehavior: _ScrollBehavior(),
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: StyledBanner.scaffoldMessengerKey,
            home: Scaffold(
              // Checks cache for previous session, tries to refresh it if
              // needed, and navigates to the appropriate page
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
