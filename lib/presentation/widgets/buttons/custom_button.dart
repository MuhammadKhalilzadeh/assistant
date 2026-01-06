import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A modern, reusable custom button widget
/// 
/// This widget provides a consistent styling and behavior for buttons
/// throughout the application, aligned with the app's modern design theme.
class CustomButton extends StatefulWidget {
  /// The text displayed on the button
  final String text;
  
  /// Callback function when button is pressed
  final VoidCallback? onPressed;
  
  /// Optional icon displayed before the text
  final IconData? icon;
  
  /// Whether the button is enabled
  final bool enabled;
  
  /// Button width (null for auto-sizing)
  final double? width;
  
  /// Whether to show loading indicator
  final bool isLoading;
  
  /// Background color (defaults to white)
  final Color? backgroundColor;
  
  /// Text color (defaults to primaryColor)
  final Color? textColor;
  
  /// Border radius
  final double borderRadius;
  
  /// Font size
  final double fontSize;
  
  /// Font weight
  final FontWeight fontWeight;
  
  /// Whether to use gradient background
  final bool useGradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.enabled = true,
    this.width,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = AppTheme.borderRadiusMedium,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.useGradient = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = widget.enabled &&
        widget.onPressed != null &&
        !widget.isLoading;
    final Color buttonBackgroundColor =
        widget.backgroundColor ?? AppTheme.surfaceColor;
    final Color buttonTextColor =
        widget.textColor ?? AppTheme.primaryColor;

    return GestureDetector(
      onTapDown: isButtonEnabled ? _handleTapDown : null,
      onTapUp: isButtonEnabled ? _handleTapUp : null,
      onTapCancel: isButtonEnabled ? _handleTapCancel : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isButtonEnabled ? widget.onPressed : null,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.useGradient && isButtonEnabled
                      ? AppTheme.primaryGradient
                      : null,
                  color: widget.useGradient
                      ? null
                      : (isButtonEnabled
                          ? buttonBackgroundColor
                          : buttonBackgroundColor.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: isButtonEnabled
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLG,
                  vertical: AppTheme.spacingMD,
                ),
                child: widget.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.useGradient
                                ? AppTheme.textOnPrimary
                                : buttonTextColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 20,
                              color: widget.useGradient
                                  ? AppTheme.textOnPrimary
                                  : buttonTextColor,
                            ),
                            const SizedBox(width: AppTheme.spacingSM),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: widget.fontSize,
                              fontWeight: widget.fontWeight,
                              color: widget.useGradient
                                  ? AppTheme.textOnPrimary
                                  : (isButtonEnabled
                                      ? buttonTextColor
                                      : buttonTextColor.withValues(alpha: 0.5)),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

