import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'provider.dart';

Future<void> goToLogin(BuildContext context) =>
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute<void>(
        builder: (context) => const LoginPage(),
      ),
      (_) => false,
    );

final class LoginPage extends StatelessWidget {
  const LoginPage({super.key}) : super();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: LoginProviderWidget(),
        ),
      );
}
