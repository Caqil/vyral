import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_text_field.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputAction textInputAction;
  final bool autofocus;
  final FocusNode? focusNode;

  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      placeholder: Text(widget.hint ?? ""),
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      //onSubmitted: widget.onSubmitted,
      prefix: const Icon(Icons.lock_outline),
      suffix: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
    );
  }
}
