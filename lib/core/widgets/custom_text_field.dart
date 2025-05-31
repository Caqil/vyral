// lib/core/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../constants/app_constants.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final Widget? placeholder;
  final String? description;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final String? suffixText;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? padding;
  final InputBorder? border;
  final Color? fillColor;
  final bool filled;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? placeholderStyle;
  final bool showPasswordToggle;

  const CustomTextField({
    super.key,
    this.label,
    this.placeholder,
    this.description,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.autofocus = false,
    this.focusNode,
    this.padding,
    this.border,
    this.fillColor,
    this.filled = true,
    this.style,
    this.labelStyle,
    this.placeholderStyle,
    this.showPasswordToggle = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late TextEditingController _controller;
  bool _shouldDisposeController = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _shouldDisposeController = true;
    }
  }

  @override
  void dispose() {
    if (_shouldDisposeController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use shadcn_ui input when possible
    if (_canUseShadInput()) {
      return _buildShadInput(context);
    }

    // Fall back to Material input for complex cases
    return _buildMaterialInput(context);
  }

  bool _canUseShadInput() {
    // Use ShadInput for simple cases
    return widget.maxLines == 1 &&
        widget.minLines == null &&
        widget.inputFormatters == null &&
        widget.prefixText == null &&
        widget.suffixText == null &&
        widget.border == null;
  }

  Widget _buildShadInput(BuildContext context) {
    final colorScheme = context.colorScheme;

    Widget? suffixWidget;
    if (widget.obscureText && widget.showPasswordToggle) {
      suffixWidget = ShadButton.ghost(
        size: ShadButtonSize.regular,
        onPressed: () => setState(() => _obscureText = !_obscureText),
        child: Icon(
          _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
          size: 16,
        ),
      );
    } else if (widget.suffix != null) {
      suffixWidget = widget.suffix;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: widget.labelStyle ??
                Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.foreground,
                    ),
          ),
          const SizedBox(height: 8),
        ],
        ShadInput(
          controller: _controller,
          placeholder: widget.placeholder,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: widget.style,
        ),
        if (widget.description != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.description!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.mutedForeground,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildMaterialInput(BuildContext context) {
    final colorScheme = context.colorScheme;

    Widget? suffixIcon;
    if (widget.obscureText && widget.showPasswordToggle) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: colorScheme.mutedForeground,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    } else if (widget.suffix != null) {
      suffixIcon = widget.suffix;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: widget.labelStyle ??
                Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.foreground,
                    ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: _controller,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          style: widget.style ??
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.foreground,
                  ),
          decoration: InputDecoration(
            prefixIcon: widget.prefix,
            suffixIcon: suffixIcon,
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            contentPadding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: widget.border ??
                OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide(color: colorScheme.border),
                ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: colorScheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: colorScheme.ring, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: colorScheme.destructive),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: colorScheme.destructive, width: 2),
            ),
            filled: widget.filled,
            fillColor: widget.fillColor ?? colorScheme.background,
            hintStyle: widget.placeholderStyle ??
                TextStyle(color: colorScheme.mutedForeground),
            counterText: widget.maxLength != null ? null : '',
          ),
        ),
        if (widget.description != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.description!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.mutedForeground,
                ),
          ),
        ],
      ],
    );
  }
}

// Form field version that works with ShadForm
class CustomFormField extends StatelessWidget {
  final String id;
  final String? label;
  final String? placeholder;
  final String? description;
  final String? initialValue;
  final String? Function(String)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextStyle? style;
  final bool showPasswordToggle;

  const CustomFormField({
    super.key,
    required this.id,
    this.label,
    this.placeholder,
    this.description,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.autofocus = false,
    this.focusNode,
    this.style,
    this.showPasswordToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      id: id,
      label: label != null ? Text(label!) : null,
      placeholder: Text(placeholder ?? ""),
      description: description != null ? Text(description!) : null,
      initialValue: initialValue,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      autofocus: autofocus,
      focusNode: focusNode,
      style: style,
    );
  }
}

// Extension to make accessing color scheme easier
extension ShadColorSchemeExtension on BuildContext {
  ShadColorScheme get colorScheme {
    final shadTheme = ShadTheme.of(this);
    return shadTheme.colorScheme;
  }
}

// Convenience constructors for common input types
extension CustomTextFieldExtensions on CustomTextField {
  static Widget email({
    Key? key,
    String? label,
    String? placeholder,
    String? description,
    String? initialValue,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool autofocus = false,
    bool enabled = true,
  }) {
    return CustomTextField(
      key: key,
      label: label ?? 'Email',
      placeholder: Text(placeholder ?? 'Enter your email'),
      description: description,
      initialValue: initialValue,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofocus: autofocus,
      enabled: enabled,
    );
  }

  static Widget password({
    Key? key,
    String? label,
    String? placeholder,
    String? description,
    String? initialValue,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool autofocus = false,
    bool enabled = true,
    bool showPasswordToggle = true,
  }) {
    return CustomTextField(
      key: key,
      label: label ?? 'Password',
      placeholder: Text(placeholder ?? 'Enter your password'),
      description: description,
      initialValue: initialValue,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      obscureText: true,
      autofocus: autofocus,
      enabled: enabled,
      showPasswordToggle: showPasswordToggle,
    );
  }

  static Widget multiline({
    Key? key,
    String? label,
    String? placeholder,
    String? description,
    String? initialValue,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 4,
    int? maxLength,
    bool autofocus = false,
    bool enabled = true,
  }) {
    return CustomTextField(
      key: key,
      label: label,
      placeholder: Text(placeholder ?? ""),
      description: description,
      initialValue: initialValue,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: autofocus,
      enabled: enabled,
    );
  }

  static Widget search({
    Key? key,
    String? placeholder,
    String? initialValue,
    TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool autofocus = false,
    bool enabled = true,
  }) {
    return CustomTextField(
      key: key,
      placeholder: Text(placeholder ?? 'Search...'),
      initialValue: initialValue,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefix: const Icon(LucideIcons.search, size: 16),
      autofocus: autofocus,
      enabled: enabled,
    );
  }
}
