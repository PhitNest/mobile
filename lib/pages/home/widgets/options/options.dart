import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../entities/entities.dart';
import '../../../../theme.dart';
import '../../../../util/bloc/bloc.dart';
import '../../../../widgets/widgets.dart';
import '../../home.dart';

class OptionsPage extends StatelessWidget {
  final UserWithEmail user;
  final Image profilePicture;

  const OptionsPage({
    super.key,
    required this.user,
    required this.profilePicture,
  }) : super();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Your Account',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  user.fullName,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium,
                ),
                profilePicture,
                // TextButton(
                //   onPressed: () => Navigator.push(
                //     context,
                //     CupertinoPageRoute<void>(
                //       builder: (_) => const AboutUsScreen(),
                //     ),
                //   ),
                //   style: TextButton.styleFrom(),
                //   child: Text(
                //     'About Us',
                //     style: theme.textTheme.bodySmall!.copyWith(
                //       fontStyle: FontStyle.normal,
                //       decoration: TextDecoration.underline,
                //       decorationStyle: TextDecorationStyle.solid,
                //     ),
                //   ),
                // ),
                StyledOutlineButton(
                  onPress: () =>
                      context.deleteUserBloc.add(const LoaderLoadEvent(null)),
                  text: 'Delete Account',
                  hPadding: 16,
                  vPadding: 8,
                ),
                StyledOutlineButton(
                  onPress: () =>
                      context.logoutBloc.add(const LoaderLoadEvent(null)),
                  text: 'Sign Out',
                  hPadding: 16,
                  vPadding: 8,
                ),
              ],
            ),
          ),
        ),
      );
}
