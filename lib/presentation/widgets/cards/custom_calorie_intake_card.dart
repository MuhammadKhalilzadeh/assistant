import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class CustomCalorieIntakeCard extends StatelessWidget {
  final int currentCalories;
  final int goalCalories;
  final VoidCallback? onTap;
  final VoidCallback? onAddPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final IconData icon;
  final bool enabled;

  const CustomCalorieIntakeCard({
    super.key,
    this.currentCalories = 0,
    this.goalCalories = 2000,
    this.onTap,
    this.onAddPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 20,
    this.icon = Icons.restaurant,
    this.enabled = true,
  });

  int get remainingCalories => (goalCalories - currentCalories).clamp(0, goalCalories);

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String get _displayText {
    if (remainingCalories <= 0) return 'Goal reached!';
    return 'Still ${_formatNumber(remainingCalories)} cal to go';
  }

  @override
  Widget build(BuildContext context) {
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
            gradient: backgroundColor == null
                ? AppTheme.secondaryGradient
                : null,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Padding(
            padding: EdgeInsets.all(responsivePadding.clamp(16.0, 24.0)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildIconWithBorder(fgColor, constraints.maxWidth),
                    SizedBox(width: constraints.maxWidth * 0.04),
                    Expanded(child: _buildTextSection(fgColor, constraints.maxWidth)),
                    SizedBox(width: constraints.maxWidth * 0.04),
                    _buildAddButton(fgColor, constraints.maxWidth),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBorder(Color fgColor, double maxWidth) {
    final double iconSize = (maxWidth * 0.08).clamp(20.0, 32.0);
    final double padding = iconSize * 0.3;
    final double borderWidth = (iconSize * 0.08).clamp(1.5, 2.5);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(color: fgColor, width: borderWidth),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: fgColor, size: iconSize),
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

  Widget _buildAddButton(Color fgColor, double maxWidth) {
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
          child: Icon(Icons.add, color: fgColor, size: iconSize),
        ),
      ),
    );
  }
}
