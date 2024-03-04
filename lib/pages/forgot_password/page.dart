import 'package:flutter/material.dart';

import 'provider.dart';

final class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key}) : super();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: ForgotPasswordProviderWidget(),
        ),
      );
}
