import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? placeholder;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.placeholder,
  });

  const CustomTextField.multiline({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.maxLines = 3,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.placeholder,
  })  : keyboardType = TextInputType.multiline,
        obscureText = false,
        prefix = null,
        suffix = null,
        onTap = null,
        inputFormatters = null;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText ? _isObscured : false,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefix,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : widget.suffix,
            counterText: widget.maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}
