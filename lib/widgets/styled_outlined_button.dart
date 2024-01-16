import 'package:flutter/material.dart';

import '../theme.dart';

final class StyledOutlineButton extends StatelessWidget {
  final String? text;
  final double? hPadding;
  final double? vPadding;
  final void Function() onPress;

  const StyledOutlineButton({
    super.key,
    required this.onPress,
    this.text,
    this.hPadding,
    this.vPadding,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onPress,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: hPadding ?? 31.5,
              vertical: vPadding ?? 18,
            ),
          ),
          side: MaterialStateProperty.all(
            BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text ?? '',
          style: theme.textTheme.bodySmall,
        ),
      );
}
