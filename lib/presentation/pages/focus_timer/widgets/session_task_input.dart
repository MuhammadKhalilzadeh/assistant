import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Task name input for focus sessions
class SessionTaskInput extends StatefulWidget {
  final String currentTask;
  final ValueChanged<String> onTaskChanged;

  const SessionTaskInput({
    super.key,
    required this.currentTask,
    required this.onTaskChanged,
  });

  @override
  State<SessionTaskInput> createState() => _SessionTaskInputState();
}

class _SessionTaskInputState extends State<SessionTaskInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  // Quick task suggestions
  final List<String> _suggestions = [
    'Deep work',
    'Code review',
    'Writing',
    'Reading',
    'Planning',
    'Learning',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTask);
    _isExpanded = widget.currentTask.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Input toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _focusNode.requestFocus();
                  });
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.currentTask.isNotEmpty
                          ? widget.currentTask
                          : 'What are you working on?',
                      style: TextStyle(
                        color: widget.currentTask.isNotEmpty
                            ? AppTheme.textPrimary
                            : AppTheme.textTertiary,
                        fontSize: 14,
                        fontWeight: widget.currentTask.isNotEmpty
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (widget.currentTask.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        widget.onTaskChanged('');
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.textTertiary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppTheme.textSecondary,
                          size: 14,
                        ),
                      ),
                    )
                  else
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppTheme.textTertiary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          // Expanded section with text field and suggestions
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: AppTheme.textTertiary.withValues(alpha: 0.2),
                  height: 1,
                ),

                // Text input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter task name...',
                      hintStyle: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: widget.onTaskChanged,
                    onSubmitted: (value) {
                      widget.onTaskChanged(value);
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                  ),
                ),

                // Quick suggestions
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick select',
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _suggestions.map((suggestion) {
                          return GestureDetector(
                            onTap: () {
                              _controller.text = suggestion;
                              widget.onTaskChanged(suggestion);
                              setState(() {
                                _isExpanded = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
