import 'package:assistant/data/services/insights_api_service.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// A card displaying a server-generated AI insight with dismiss action.
class ServerInsightCard extends StatelessWidget {
  final ServerInsight insight;
  final VoidCallback? onDismiss;

  const ServerInsightCard({
    super.key,
    required this.insight,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(insight.type);
    final icon = _iconForType(insight.type);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        insight.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    // Confidence badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(insight.confidence * 100).round()}%',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  insight.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (onDismiss != null) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: onDismiss,
                      child: Text(
                        'Dismiss',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForType(String type) {
    return switch (type) {
      'suggestion' => AppTheme.primaryColor,
      'trend' => const Color(0xFF6366F1),
      'anomaly' => AppTheme.warningColor,
      'pattern' => AppTheme.successColor,
      'correlation' => const Color(0xFF8B5CF6),
      _ => AppTheme.textSecondary,
    };
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'suggestion' => Icons.lightbulb_outlined,
      'trend' => Icons.trending_up_outlined,
      'anomaly' => Icons.warning_amber_outlined,
      'pattern' => Icons.auto_graph_outlined,
      'correlation' => Icons.compare_arrows_outlined,
      _ => Icons.insights_outlined,
    };
  }
}
