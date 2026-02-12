import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/models/meditation_session_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Meditation history list with swipe-to-delete functionality
class MeditationHistoryList extends StatelessWidget {
  final List<MeditationSessionModel> sessions;
  final Function(String id) onDelete;
  final double padding;
  final Animation<double>? animation;

  const MeditationHistoryList({
    super.key,
    required this.sessions,
    required this.onDelete,
    required this.padding,
    this.animation,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return 'Today';
    } else if (sessionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  IconData _getSessionIcon(MeditationType type) {
    switch (type) {
      case MeditationType.breathing:
        return Icons.air;
      case MeditationType.guided:
        return Icons.headphones;
      case MeditationType.unguided:
        return Icons.self_improvement;
      case MeditationType.sleep:
        return Icons.bedtime;
      case MeditationType.focus:
        return Icons.center_focus_strong;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentSessions = sessions
        .where((s) => s.isCompleted)
        .take(10)
        .toList();

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
              'Recent Sessions',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (recentSessions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${recentSessions.length} sessions',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentSessions.isEmpty)
          _buildEmptyState()
        else
          ...recentSessions.asMap().entries.map((entry) {
            final index = entry.key;
            final session = entry.value;
            return _MeditationHistoryItem(
              session: session,
              dateString: _formatDate(session.startTime),
              timeString: _formatTime(session.startTime),
              sessionIcon: _getSessionIcon(session.type),
              onDelete: () => onDelete(session.id),
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
            Icons.self_improvement,
            size: 48,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No sessions yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start your first meditation session',
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

class _MeditationHistoryItem extends StatefulWidget {
  final MeditationSessionModel session;
  final String dateString;
  final String timeString;
  final IconData sessionIcon;
  final VoidCallback onDelete;
  final double padding;
  final int delay;

  const _MeditationHistoryItem({
    required this.session,
    required this.dateString,
    required this.timeString,
    required this.sessionIcon,
    required this.onDelete,
    required this.padding,
    required this.delay,
  });

  @override
  State<_MeditationHistoryItem> createState() => _MeditationHistoryItemState();
}

class _MeditationHistoryItemState extends State<_MeditationHistoryItem>
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dismissible(
          key: Key(widget.session.id),
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
                // Icon with type
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.sessionIcon,
                    color: AppTheme.primaryColor,
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
                            widget.session.typeLabel,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
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
                              'Completed',
                              style: TextStyle(
                                color: AppTheme.successColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            widget.dateString,
                            style: TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.timeString,
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
                // Duration
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.session.durationMinutes}',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'min',
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
