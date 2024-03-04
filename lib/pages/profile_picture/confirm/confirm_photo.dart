import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../../util/util.dart';
import '../../../widgets/widgets.dart';
import 'bloc.dart';

final class ConfirmPhotoWidget extends StatelessWidget {
  final Image pfp;
  final bool loading;

  const ConfirmPhotoWidget({
    super.key,
    required this.pfp,
    required this.loading,
  }) : super();

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          pfp,
          if (loading)
            const Loader()
          else ...[
            ElevatedButton(
              onPressed: context.confirmPhotoBloc.load,
              child: Text(
                'CONFIRM',
                style: theme.textTheme.bodySmall,
              ),
            ),
            StyledOutlineButton(
              text: 'BACK',
              onPress: Navigator.of(context).pop,
            ),
          ],
        ],
      );
}
