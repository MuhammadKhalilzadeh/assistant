import 'package:flutter/material.dart';

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
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFirstTime ? Icons.emoji_events_outlined : Icons.history_rounded,
              color: Colors.white.withValues(alpha: 0.6),
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
              color: Colors.white,
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
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
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
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.withValues(alpha: 0.8),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isFirstTime
                        ? 'Tip: Start with 25 min sessions'
                        : 'Tip: Short breaks boost focus',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
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
