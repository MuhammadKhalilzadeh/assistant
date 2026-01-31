import 'package:flutter/material.dart';
import 'package:assistant/data/mock/models/focus_session_model.dart';
import 'session_item.dart';
import 'focus_empty_state.dart';

/// List of recent focus sessions grouped by date
class SessionHistory extends StatelessWidget {
  final List<FocusSessionModel> sessions;
  final ValueChanged<String>? onSessionDelete;

  const SessionHistory({
    super.key,
    required this.sessions,
    this.onSessionDelete,
  });

  @override
  Widget build(BuildContext context) {
    final completedSessions =
        sessions.where((s) => s.isCompleted).toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (completedSessions.isEmpty) {
      return const FocusEmptyState();
    }

    // Group sessions by date
    final grouped = _groupByDate(completedSessions);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recent Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${completedSessions.length} total',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: Colors.white.withValues(alpha: 0.1),
            height: 1,
          ),

          // Sessions list
          ...grouped.entries.take(3).expand((entry) {
            return [
              // Date header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTotalTime(entry.value),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Session items for this date
              ...entry.value.take(5).map((session) => SessionItem(
                    session: session,
                    onDelete: onSessionDelete != null
                        ? () => onSessionDelete!(session.id)
                        : null,
                  )),
            ];
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Map<String, List<FocusSessionModel>> _groupByDate(
      List<FocusSessionModel> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<FocusSessionModel>>{};

    for (final session in sessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      String label;
      if (sessionDate == today) {
        label = 'Today';
      } else if (sessionDate == yesterday) {
        label = 'Yesterday';
      } else if (now.difference(session.startTime).inDays < 7) {
        label = 'This Week';
      } else {
        label = 'Earlier';
      }

      grouped.putIfAbsent(label, () => []).add(session);
    }

    return grouped;
  }

  String _formatTotalTime(List<FocusSessionModel> sessions) {
    final totalMinutes =
        sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    if (totalMinutes >= 60) {
      final hours = totalMinutes ~/ 60;
      final mins = totalMinutes % 60;
      return '${hours}h ${mins}m total';
    }
    return '${totalMinutes}m total';
  }
}
