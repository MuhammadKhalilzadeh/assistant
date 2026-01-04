import 'package:assistant/presentation/constants/ui.dart';
import 'package:flutter/material.dart';

/// A reusable water intake tracker card widget
///
/// This widget displays water intake tracking with customizable
/// current intake, goal, and an add button. It features a red background
/// with white text and a glass icon with fill level indicator.
class CustomWaterIntakeCard extends StatelessWidget {
  /// Current water intake in ml
  final int currentIntake;

  /// Goal water intake in ml
  final int goalIntake;

  /// Callback when the entire card is tapped
  final VoidCallback? onTap;

  /// Callback when the add button is pressed
  final VoidCallback? onAddPressed;

  /// Background color (defaults to primaryColor - red)
  final Color? backgroundColor;

  /// Foreground/text color (defaults to white)
  final Color? foregroundColor;

  /// Border radius for the card
  final double borderRadius;

  /// Icon to display
  final IconData icon;

  /// Whether the card is enabled
  final bool enabled;

  const CustomWaterIntakeCard({
    super.key,
    this.currentIntake = 0,
    this.goalIntake = 3000,
    this.onTap,
    this.onAddPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 20,
    this.icon = Icons.local_drink_outlined,
    this.enabled = true,
  });

  /// Calculate remaining intake
  int get remainingIntake => (goalIntake - currentIntake).clamp(0, goalIntake);

  /// Calculate progress as a value between 0.0 and 1.0
  double get progress =>
      goalIntake > 0 ? (currentIntake / goalIntake).clamp(0.0, 1.0) : 0.0;

  /// Format number with comma separators
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Generate display text
  String get _displayText {
    if (remainingIntake <= 0) {
      return 'Goal reached!';
    }
    return 'Still ${_formatNumber(remainingIntake)} ml to go';
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? primaryColor;
    final Color fgColor = foregroundColor ?? Colors.white;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsivePadding = screenWidth * 0.05;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(responsivePadding.clamp(16.0, 24.0)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left section: Glass icon with fill level
                    _buildGlassIcon(bgColor, fgColor, constraints.maxWidth),

                    SizedBox(width: constraints.maxWidth * 0.04),

                    // Center section: Text
                    Expanded(
                      child: _buildTextSection(fgColor, constraints.maxWidth),
                    ),

                    SizedBox(width: constraints.maxWidth * 0.04),

                    // Right section: Add button
                    _buildAddButton(bgColor, fgColor, constraints.maxWidth),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIcon(Color bgColor, Color fgColor, double maxWidth) {
    final double iconSize = (maxWidth * 0.1).clamp(28.0, 40.0);
    final double containerSize = iconSize * 1.6;

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: CustomPaint(
        painter: _GlassPainter(
          fillLevel: progress,
          glassColor: fgColor,
          fillColor: fgColor.withValues(alpha: 0.4),
        ),
        child: Center(
          child: Icon(
            icon,
            color: fgColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection(Color fgColor, double maxWidth) {
    final double fontSize = (maxWidth * 0.055).clamp(16.0, 22.0);

    return Text(
      _displayText,
      style: TextStyle(
        color: fgColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAddButton(Color bgColor, Color fgColor, double maxWidth) {
    final double buttonSize = (maxWidth * 0.12).clamp(40.0, 56.0);
    final double iconSize = (maxWidth * 0.06).clamp(20.0, 28.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onAddPressed : null,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Ink(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: fgColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add,
            color: fgColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for drawing a glass with fill level
class _GlassPainter extends CustomPainter {
  final double fillLevel;
  final Color glassColor;
  final Color fillColor;

  _GlassPainter({
    required this.fillLevel,
    required this.glassColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // No additional painting needed - using the icon instead
  }

  @override
  bool shouldRepaint(covariant _GlassPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.glassColor != glassColor ||
        oldDelegate.fillColor != fillColor;
  }
}
