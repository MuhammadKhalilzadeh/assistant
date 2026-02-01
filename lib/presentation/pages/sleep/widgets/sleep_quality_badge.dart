import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/sleep_record_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Reusable quality indicator component for sleep quality
class SleepQualityBadge extends StatelessWidget {
  final SleepQuality quality;
  final bool showLabel;
  final double size;

  const SleepQualityBadge({
    super.key,
    required this.quality,
    this.showLabel = true,
    this.size = 1.0,
  });

  static String getQualityLabel(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return 'Poor';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.good:
        return 'Good';
      case SleepQuality.excellent:
        return 'Excellent';
    }
  }

  static Color getQualityColor(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return AppTheme.errorColor;
      case SleepQuality.fair:
        return AppTheme.warningColor;
      case SleepQuality.good:
        return const Color(0xFF84CC16); // Light green
      case SleepQuality.excellent:
        return AppTheme.successColor;
    }
  }

  static IconData getQualityIcon(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return Icons.sentiment_very_dissatisfied;
      case SleepQuality.fair:
        return Icons.sentiment_neutral;
      case SleepQuality.good:
        return Icons.sentiment_satisfied;
      case SleepQuality.excellent:
        return Icons.sentiment_very_satisfied;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getQualityColor(quality);
    final label = getQualityLabel(quality);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * size,
        vertical: 8 * size,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20 * size),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getQualityIcon(quality),
            color: color,
            size: 16 * size,
          ),
          if (showLabel) ...[
            SizedBox(width: 6 * size),
            Text(
              '$label Sleep',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13 * size,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small quality indicator bar used in list items
class SleepQualityBar extends StatelessWidget {
  final SleepQuality quality;
  final double height;

  const SleepQualityBar({
    super.key,
    required this.quality,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: SleepQualityBadge.getQualityColor(quality),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
