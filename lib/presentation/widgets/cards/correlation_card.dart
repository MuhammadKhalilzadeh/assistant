import 'package:assistant/data/services/insights_api_service.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A card displaying a correlation between two data domains.
class CorrelationCard extends StatelessWidget {
  final Correlation correlation;

  const CorrelationCard({super.key, required this.correlation});

  @override
  Widget build(BuildContext context) {
    final color = correlation.direction == 'positive'
        ? AppTheme.successColor
        : AppTheme.warningColor;
    final strengthIcon = correlation.strength == 'strong'
        ? Icons.link
        : Icons.link_outlined;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(strengthIcon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_featureLabel(correlation.featureA)} & ${_featureLabel(correlation.featureB)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  correlation.strength,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            correlation.humanReadable,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          // Correlation bar
          Row(
            children: [
              Text(
                'r = ${correlation.coefficient.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: correlation.coefficient.abs(),
                    backgroundColor: AppTheme.cardBorderColor,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _featureLabel(String feature) {
    return switch (feature) {
      'steps' => 'Steps',
      'sleepHours' => 'Sleep',
      'sleepQuality' => 'Sleep Quality',
      'moodScore' => 'Mood',
      'waterMl' => 'Water',
      'workoutMinutes' => 'Workout',
      'meditationMinutes' => 'Meditation',
      'focusMinutes' => 'Focus',
      'screenTime' => 'Screen Time',
      'heartRate' => 'Heart Rate',
      'calories' => 'Calories',
      _ => feature,
    };
  }
}
