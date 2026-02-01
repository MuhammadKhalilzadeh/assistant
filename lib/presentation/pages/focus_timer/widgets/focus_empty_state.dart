import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Empty state widget for when there are no focus sessions
class FocusEmptyState extends StatelessWidget {
  final bool isFirstTime;

  const FocusEmptyState({
    super.key,
    this.isFirstTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFirstTime ? Icons.emoji_events_outlined : Icons.history_rounded,
              color: AppTheme.primaryColor,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            isFirstTime
                ? 'Welcome to Focus Timer!'
                : 'No sessions yet today',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Message
          Text(
            isFirstTime
                ? 'Start your first focus session and boost your productivity. The Pomodoro technique helps you stay focused!'
                : 'Complete a focus session to see your progress here. Every session counts!',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Motivational tip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isFirstTime
                        ? 'Tip: Start with 25 min sessions'
                        : 'Tip: Short breaks boost focus',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
