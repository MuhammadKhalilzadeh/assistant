import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:assistant/data/models/screen_time_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Pie chart showing app usage breakdown
class AppUsageChart extends StatelessWidget {
  final List<AppUsageEntry> appUsage;
  final double padding;
  final Animation<double>? animation;

  const AppUsageChart({
    super.key,
    required this.appUsage,
    required this.padding,
    this.animation,
  });

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.infoColor,
      AppTheme.warningColor,
      AppTheme.successColor,
      AppTheme.errorColor,
      AppTheme.primaryLight,
    ];
    return colors[index % colors.length];
  }

  IconData _getIconForApp(String iconName) {
    switch (iconName) {
      case 'people':
        return Icons.people;
      case 'email':
        return Icons.email;
      case 'language':
        return Icons.language;
      case 'games':
        return Icons.games;
      default:
        return Icons.apps;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (appUsage.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalMinutes = appUsage.fold(0, (sum, app) => sum + app.minutesUsed);

    Widget content = Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'App Breakdown',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatTime(totalMinutes),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie chart
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _PieChartPainter(
                    data: appUsage.map((app) => app.minutesUsed.toDouble()).toList(),
                    colors: List.generate(appUsage.length, (i) => _getColorForIndex(i)),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: appUsage.asMap().entries.map((entry) {
                    final index = entry.key;
                    final app = entry.value;
                    final percentage = (app.minutesUsed / totalMinutes * 100).round();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getColorForIndex(index),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _getIconForApp(app.iconName),
                            color: AppTheme.textTertiary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              app.appName,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Usage bars
          ...appUsage.asMap().entries.map((entry) {
            final index = entry.key;
            final app = entry.value;
            final percentage = app.minutesUsed / totalMinutes;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AppUsageBar(
                appName: app.appName,
                iconName: app.iconName,
                minutes: app.minutesUsed,
                percentage: percentage,
                color: _getColorForIndex(index),
              ),
            );
          }),
        ],
      ),
    );

    if (animation != null) {
      return FadeTransition(
        opacity: animation!,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation!,
            curve: Curves.easeOutCubic,
          )),
          child: content,
        ),
      );
    }

    return content;
  }
}

class _AppUsageBar extends StatelessWidget {
  final String appName;
  final String iconName;
  final int minutes;
  final double percentage;
  final Color color;

  const _AppUsageBar({
    required this.appName,
    required this.iconName,
    required this.minutes,
    required this.percentage,
    required this.color,
  });

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  IconData _getIconForApp(String iconName) {
    switch (iconName) {
      case 'people':
        return Icons.people;
      case 'email':
        return Icons.email;
      case 'language':
        return Icons.language;
      case 'games':
        return Icons.games;
      default:
        return Icons.apps;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForApp(iconName),
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  appName,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                _formatTime(minutes),
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;

  _PieChartPainter({
    required this.data,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final total = data.fold(0.0, (sum, value) => sum + value);

    if (total == 0) return;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i] / total) * 2 * math.pi;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.02, // Small gap between segments
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Inner circle
    final innerPaint = Paint()
      ..color = AppTheme.cardColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 20, innerPaint);

    // Center icon
    final iconPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 20, iconPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.colors != colors;
  }
}
