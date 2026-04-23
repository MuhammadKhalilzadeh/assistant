import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool enabled;

  const ChatInput({
    super.key,
    required this.onSend,
    this.enabled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(color: AppTheme.textTertiary),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 1,
                    ),
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _hasText && widget.enabled ? _handleSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hasText && widget.enabled
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: AppTheme.textOnPrimary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
