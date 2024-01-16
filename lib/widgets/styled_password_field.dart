import 'package:flutter/material.dart';

import 'styled_underline_text_field.dart';

final class StyledPasswordField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final String? Function(dynamic)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  const StyledPasswordField({
    super.key,
    this.hint,
    this.controller,
    this.textInputAction,
    this.focusNode,
    this.onEditingComplete,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  }) : super();

  @override
  StyledPasswordFieldState createState() => StyledPasswordFieldState();
}

final class StyledPasswordFieldState extends State<StyledPasswordField> {
  bool _obscureText = true;

  final iconButtonNode = FocusNode()..skipTraversal = true;

  StyledPasswordFieldState() : super();

  @override
  Widget build(BuildContext context) => StyledUnderlinedTextField(
        onFieldSubmitted: widget.onFieldSubmitted,
        hint: widget.hint,
        errorMaxLines: 2,
        controller: widget.controller,
        obscureText: _obscureText,
        textInputAction: widget.textInputAction,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.visiblePassword,
        onEditingComplete: widget.onEditingComplete,
        onChanged: widget.onChanged,
        validator: widget.validator,
        suffix: IconButton(
          focusNode: iconButtonNode,
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.visibility,
            color: _obscureText ? Colors.grey : Colors.white,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      );

  @override
  void dispose() {
    iconButtonNode.dispose();
    super.dispose();
  }
}
