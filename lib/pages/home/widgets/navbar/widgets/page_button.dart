import 'package:flutter/material.dart';

final class NavBarPageButton extends StatelessWidget {
  final String text;
  final bool selected;
  final bool reversed;
  final void Function() onPressed;

  const NavBarPageButton({
    super.key,
    required this.text,
    required this.selected,
    required this.reversed,
    required this.onPressed,
  }) : super();

  @override
  Widget build(BuildContext context) => TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
        onPressed: !selected ? onPressed : null,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: reversed
                    ? selected
                        ? Colors.white
                        : Color.fromARGB((0.7 * 255).round(), 255, 255, 255)
                    : selected
                        ? Colors.black
                        : Color.fromARGB((0.4 * 255).round(), 0, 0, 0),
              ),
        ),
      );
}
