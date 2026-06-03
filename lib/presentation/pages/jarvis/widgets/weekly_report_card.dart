import 'package:assistant/data/services/jarvis_insights_service.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/providers/insights_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A collapsible weekly comparison card shown at the top of the Home tab.
class WeeklyReportCard extends ConsumerStatefulWidget {
  const WeeklyReportCard({super.key});

  @override
  ConsumerState<WeeklyReportCard> createState() => _WeeklyReportCardState();
}

class _WeeklyReportCardState extends ConsumerState<WeeklyReportCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insightsProvider);
    final report = state.weeklyReport;

    if (report == null || report.metrics.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: Column(
        children: [
          // Header — tap to expand/collapse
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart_rounded,
                      size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 6),
                  const Text(
                    'Weekly Report Card',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  if (report.highlights.isNotEmpty)
                    _buildChip(
                      '\u2713 ${report.highlights.length}',
                      AppTheme.successColor,
                    ),
                  if (report.needsAttention.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    _buildChip(
                      '! ${report.needsAttention.length}',
                      AppTheme.warningColor,
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppTheme.textTertiary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded) ...[
            const Divider(height: 1, color: AppTheme.dividerColor),

            if (report.highlights.isNotEmpty)
              _buildSection(
                'Highlights',
                Icons.star_rounded,
                AppTheme.successColor,
                report.highlights,
              ),

            if (report.needsAttention.isNotEmpty)
              _buildSection(
                'Needs Attention',
                Icons.flag_rounded,
                AppTheme.warningColor,
                report.needsAttention,
              ),

            // Metrics grid
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 8.0;
                  final tileWidth =
                      ((constraints.maxWidth - spacing * 2) / 3).clamp(90.0, double.infinity);
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: report.metrics
                        .map((m) => _buildMetricTile(m, tileWidth))
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: items.map((item) => _buildChip(item, color)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(WeeklyMetric metric, double tileWidth) {
    final pctOfGoal = metric.progress;
    final color = pctOfGoal >= 0.8
        ? AppTheme.successColor
        : (pctOfGoal >= 0.5 ? AppTheme.warningColor : AppTheme.textTertiary);

    return SizedBox(
      width: tileWidth,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatValue(metric.value, metric.unit),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                if (metric.streak > 0) ...[
                  Icon(Icons.local_fire_department, size: 10, color: color),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      '${metric.streak}d',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  '${(pctOfGoal * 100).round()}%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value, String unit) {
    final formatted = value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
    return '$formatted ${unit.split('/').first}';
  }
}
