import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const PasswordInput({
    super.key,
    required this.controller,
    this.placeholder = 'Enter password',
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadInput(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      placeholder: Text(widget.placeholder),
      leading: Padding(
        padding: const EdgeInsets.only(left: 4, right: 8),
        child: Icon(
          LucideIcons.lock,
          size: 16,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
      trailing: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _obscure = !_obscure;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            _obscure ? LucideIcons.eyeOff : LucideIcons.eye,
            size: 16,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}
