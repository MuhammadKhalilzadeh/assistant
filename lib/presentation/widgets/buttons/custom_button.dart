import 'package:assistant/presentation/constants/ui.dart';
import 'package:flutter/material.dart';

/// A reusable custom button widget
/// 
/// This widget provides a consistent styling and behavior for buttons
/// throughout the application, aligned with the app's design theme.
class CustomButton extends StatelessWidget {
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
    this.borderRadius = 12,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = enabled && onPressed != null && !isLoading;
    final Color buttonBackgroundColor = backgroundColor ?? Colors.white;
    final Color buttonTextColor = textColor ?? primaryColor;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          foregroundColor: buttonTextColor,
          disabledBackgroundColor: buttonBackgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: buttonTextColor.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

