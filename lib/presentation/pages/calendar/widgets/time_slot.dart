import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Hour slot for day/week timeline views
class TimeSlot extends StatelessWidget {
  final int hour;
  final bool isCurrentHour;
  final double currentMinuteOffset;
  final VoidCallback? onTap;
  final Widget? eventWidget;

  const TimeSlot({
    super.key,
    required this.hour,
    this.isCurrentHour = false,
    this.currentMinuteOffset = 0,
    this.onTap,
    this.eventWidget,
  });

  String _formatHour(int hour) {
    if (hour == 0 || hour == 24) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8),
                    child: Text(
                      _formatHour(hour),
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: AppTheme.dividerColor,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: eventWidget,
                  ),
                ),
              ],
            ),
            if (isCurrentHour) _buildCurrentTimeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimeIndicator() {
    return Positioned(
      top: currentMinuteOffset - 5,
      left: 55,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
