import 'package:flutter/material.dart';

import '../../../theme.dart';

final class StyledIndicator extends StatelessWidget {
  final int count;
  final Widget child;
  final Size offset;

  const StyledIndicator({
    super.key,
    required this.child,
    required this.count,
    required this.offset,
  }) : super();

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          child,
          Visibility(
            visible: count > 0,
            child: Positioned(
              right: offset.width,
              top: offset.height,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(32),
                ),
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
