import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A compact daily briefing card shown at the top of the Jarvis chat.
/// Displays structured data from all user providers in a scannable format.
class DailyBriefing extends StatelessWidget {
  final String briefingData;
  final VoidCallback onRefresh;

  const DailyBriefing({
    super.key,
    required this.briefingData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final lines = briefingData
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient accent bar
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Your Day at a Glance',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onRefresh,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.refresh,
                      size: 16,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Data rows — compact, scrollable if many
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Wrap(
              spacing: 0,
              runSpacing: 2,
              children: lines.map((line) => _buildDataRow(line)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String line) {
    // Parse "Domain: value" format
    final colonIndex = line.indexOf(':');
    if (colonIndex <= 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Text(
          line,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
      );
    }

    final domain = line.substring(0, colonIndex).trim();
    final value = line.substring(colonIndex + 1).trim();
    final icon = _domainIcon(domain);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: AppTheme.textTertiary),
          const SizedBox(width: 5),
          Text(
            '$domain: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _domainIcon(String domain) {
    return switch (domain.toLowerCase()) {
      'weather' => Icons.wb_sunny_outlined,
      'sleep' => Icons.bedtime_outlined,
      'calendar' => Icons.calendar_today_outlined,
      'todos' => Icons.check_circle_outline,
      'habits' => Icons.repeat,
      'water' => Icons.water_drop_outlined,
      'mood' => Icons.emoji_emotions_outlined,
      'calories' => Icons.restaurant_outlined,
      'steps' => Icons.directions_walk_outlined,
      'workout' => Icons.fitness_center_outlined,
      'focus' => Icons.timer_outlined,
      'meditation' => Icons.self_improvement_outlined,
      'heart rate' => Icons.favorite_outline,
      'screen time' => Icons.phone_android_outlined,
      'inbox' => Icons.mail_outline,
      _ => Icons.circle,
    };
  }
}
