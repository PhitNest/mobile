import 'package:flutter/material.dart';

import '../../entities/api/api.dart';

class MessageItemWidget extends StatelessWidget {
  final Message message;
  final String userId;

  bool get sent => message.senderId == userId;

  const MessageItemWidget({
    super.key,
    required this.message,
    required this.userId,
  }) : super();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Container(
          alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.all(8),
          width: constraints.maxWidth * 0.7,
          child: Text(
            message.content,
            textAlign: sent ? TextAlign.right : TextAlign.left,
          ),
        ),
      );
}
