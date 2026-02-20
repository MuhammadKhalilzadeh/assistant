import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class TodoSummaryCard extends StatelessWidget {
  final int total;
  final int completed;
  final int todayCount;
  final int overdueCount;

  const TodoSummaryCard({
    super.key,
    required this.total,
    required this.completed,
    required this.todayCount,
    required this.overdueCount,
  });

  double get _progress => total > 0 ? completed / total : 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Progress info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Progress',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed of $total tasks completed',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Right side - Animated percentage circle
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 6,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '${(value * 100).round()}%',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _buildStatItem(
                icon: Icons.today_rounded,
                label: 'Today',
                value: todayCount.toString(),
                color: AppTheme.primaryColor,
              ),
              _buildDivider(),
              _buildStatItem(
                icon: Icons.warning_amber_rounded,
                label: 'Overdue',
                value: overdueCount.toString(),
                color: overdueCount > 0
                    ? AppTheme.errorColor
                    : AppTheme.textTertiary,
              ),
              _buildDivider(),
              _buildStatItem(
                icon: Icons.check_circle_outline_rounded,
                label: 'Done',
                value: completed.toString(),
                color: AppTheme.successColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 8,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.cardBorderColor,
    );
  }
}
