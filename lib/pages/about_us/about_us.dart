import 'package:flutter/material.dart';

import '../../theme.dart';

final class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key}) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 32,
            ),
          ),
          title: Text(
            'About US',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () => {},
                style: TextButton.styleFrom(),
                child: Text(
                  'Terms of Service',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontStyle: FontStyle.normal,
                    decorationStyle: TextDecorationStyle.solid,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => {},
                style: TextButton.styleFrom(),
                child: Text(
                  'Privacy Policy',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontStyle: FontStyle.normal,
                    decorationStyle: TextDecorationStyle.solid,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => {},
                style: TextButton.styleFrom(),
                child: Text(
                  'Software Licenses',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontStyle: FontStyle.normal,
                    decorationStyle: TextDecorationStyle.solid,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
