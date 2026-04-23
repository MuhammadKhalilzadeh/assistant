import 'package:assistant/data/models/chat_message_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isError = message.isError;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
            decoration: BoxDecoration(
              gradient: isUser ? AppTheme.primaryGradient : null,
              color: isUser ? null : AppTheme.surfaceColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isUser ? 12 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 12),
              ),
              border: isError
                  ? Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.4),
                    )
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 14,
                          color: AppTheme.errorColor.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.errorColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isUser ? AppTheme.textOnPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isUser
                        ? AppTheme.textOnPrimary.withValues(alpha: 0.7)
                        : AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
