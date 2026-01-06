import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A reusable custom text field widget
/// 
/// This widget provides a consistent styling and behavior for text fields
/// throughout the application. It can be customized with various parameters.
class CustomTextField extends StatefulWidget {
  /// The label text displayed above the text field
  final String? label;
  
  /// The hint text displayed inside the text field when empty
  final String? hint;
  
  /// The controller for the text field
  final TextEditingController? controller;
  
  /// Whether the text field is obscured (for passwords)
  final bool obscureText;
  
  /// The keyboard type
  final TextInputType? keyboardType;
  
  /// The validator function for form validation
  final String? Function(String?)? validator;
  
  /// The prefix icon
  final IconData? prefixIcon;
  
  /// The suffix icon
  final Widget? suffixIcon;
  
  /// Maximum number of lines
  final int? maxLines;
  
  /// Whether the field is enabled
  final bool enabled;
  
  /// Callback when text changes
  final void Function(String)? onChanged;
  
  /// Callback when field is submitted
  final void Function(String)? onSubmitted;
  
  /// Focus node for the text field
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    border: Border.all(
                      color: _isFocused
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.2),
                      width: _isFocused ? 2 : 1,
                    ),
                    boxShadow: _isFocused
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: TextFormField(
                    controller: widget.controller,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    validator: widget.validator,
                    maxLines: widget.maxLines,
                    enabled: widget.enabled,
                    onChanged: widget.onChanged,
                    onFieldSubmitted: widget.onSubmitted,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                      prefixIcon: widget.prefixIcon != null 
                          ? Icon(
                              widget.prefixIcon,
                              color: Colors.white.withValues(alpha: 0.9),
                            ) 
                          : null,
                      suffixIcon: widget.suffixIcon,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMD,
                        vertical: AppTheme.spacingMD,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

