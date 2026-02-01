import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/mock/models/step_record_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Steps history list with swipe-to-delete functionality
class StepsHistoryList extends StatelessWidget {
  final List<StepRecordModel> records;
  final Function(String id) onDelete;
  final double padding;
  final Animation<double>? animation;

  const StepsHistoryList({
    super.key,
    required this.records,
    required this.onDelete,
    required this.padding,
    this.animation,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return 'Today';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Show only last 7 days of records
    final recentRecords = records.take(7).toList();

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Recent History',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (recentRecords.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${recentRecords.length} days',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentRecords.isEmpty)
          _buildEmptyState()
        else
          ...recentRecords.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            return _StepsHistoryItem(
              record: record,
              dateString: _formatDate(record.date),
              formattedSteps: _formatNumber(record.steps),
              onDelete: () => onDelete(record.id),
              padding: padding,
              delay: index * 80,
            );
          }),
      ],
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.directions_walk_outlined,
            size: 48,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No step records yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start walking to track your progress',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsHistoryItem extends StatefulWidget {
  final StepRecordModel record;
  final String dateString;
  final String formattedSteps;
  final VoidCallback onDelete;
  final double padding;
  final int delay;

  const _StepsHistoryItem({
    required this.record,
    required this.dateString,
    required this.formattedSteps,
    required this.onDelete,
    required this.padding,
    required this.delay,
  });

  @override
  State<_StepsHistoryItem> createState() => _StepsHistoryItemState();
}

class _StepsHistoryItemState extends State<_StepsHistoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metGoal = widget.record.steps >= widget.record.goal;
    final progress = (widget.record.steps / widget.record.goal).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dismissible(
          key: Key(widget.record.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            widget.onDelete();
          },
          background: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete_outline,
              color: AppTheme.errorColor,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(widget.padding),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                // Icon with status
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: metGoal
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    metGoal ? Icons.emoji_events : Icons.directions_walk,
                    color: metGoal ? AppTheme.successColor : AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.dateString,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          if (metGoal) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Goal Met',
                                style: TextStyle(
                                  color: AppTheme.successColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            metGoal ? AppTheme.successColor : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Stats row
                      Row(
                        children: [
                          Text(
                            '${widget.record.distanceKm.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${widget.record.caloriesBurned} cal',
                            style: TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Steps count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.formattedSteps,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'steps',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
