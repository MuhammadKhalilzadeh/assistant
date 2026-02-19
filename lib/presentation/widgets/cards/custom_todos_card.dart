import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A reusable todos card widget
///
/// This widget displays todo/task information with customizable
/// total and completed counts. It features a white background
/// with dark text and red accents.
class CustomTodosCard extends StatelessWidget {
  /// Card title
  final String title;

  /// Total number of todos
  final int totalTodos;

  /// Number of completed todos
  final int completedTodos;

  /// Callback when the entire card is tapped
  final VoidCallback? onTap;

  /// Callback when the add button is pressed
  final VoidCallback? onAddPressed;

  /// Background color (defaults to white)
  final Color? backgroundColor;

  /// Accent color for icons and highlights (defaults to primaryColor - red)
  final Color? accentColor;

  /// Border radius for the card
  final double borderRadius;

  /// Icon to display
  final IconData icon;

  /// Whether the card is enabled
  final bool enabled;

  const CustomTodosCard({
    super.key,
    this.title = 'Todos',
    this.totalTodos = 0,
    this.completedTodos = 0,
    this.onTap,
    this.onAddPressed,
    this.backgroundColor,
    this.accentColor,
    this.borderRadius = 20,
    this.icon = Icons.check_box_outlined,
    this.enabled = true,
  });

  /// Calculate pending todos
  int get pendingTodos => (totalTodos - completedTodos).clamp(0, totalTodos);

  /// Generate subtitle text
  String get _subtitleText {
    if (totalTodos == 0) {
      return 'No tasks yet';
    }
    if (pendingTodos == 0) {
      return 'All done!';
    }
    final taskText = pendingTodos == 1 ? 'task' : 'tasks';
    return '$pendingTodos $taskText remaining';
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = accentColor ?? AppTheme.primaryColor;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsivePadding = screenWidth * 0.05;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.cardColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppTheme.cardBorderColor, width: 1),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Padding(
            padding: EdgeInsets.all(responsivePadding.clamp(16.0, 24.0)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left section: Icon with border
                    _buildIconWithBorder(accent, constraints.maxWidth),

                    SizedBox(width: constraints.maxWidth * 0.04),

                    // Center section: Title + Subtitle
                    Expanded(
                      child: _buildTextSection(constraints.maxWidth),
                    ),

                    SizedBox(width: constraints.maxWidth * 0.04),

                    // Right section: Add button
                    _buildAddButton(accent, constraints.maxWidth),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBorder(Color accent, double maxWidth) {
    final double iconSize = (maxWidth * 0.08).clamp(20.0, 32.0);
    final double padding = iconSize * 0.3;
    final double borderWidth = (iconSize * 0.08).clamp(1.5, 2.5);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(color: accent, width: borderWidth),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: accent,
        size: iconSize,
      ),
    );
  }

  Widget _buildTextSection(double maxWidth) {
    final double titleFontSize = (maxWidth * 0.055).clamp(16.0, 22.0);
    final double subtitleFontSize = (maxWidth * 0.038).clamp(12.0, 16.0);
    final double spacing = (maxWidth * 0.015).clamp(4.0, 8.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          title,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing),
        // Subtitle
        Text(
          _subtitleText,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(Color accent, double maxWidth) {
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
            color: accent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add,
            color: accent,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
