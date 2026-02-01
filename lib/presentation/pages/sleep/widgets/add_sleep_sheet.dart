import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/mock/models/sleep_record_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'sleep_quality_badge.dart';

/// Bottom sheet for logging sleep with time pickers and quality selection
class AddSleepSheet extends StatefulWidget {
  final Function(DateTime bedTime, DateTime wakeTime, SleepQuality quality) onAdd;

  const AddSleepSheet({
    super.key,
    required this.onAdd,
  });

  /// Static method to show the sheet
  static Future<void> show(
    BuildContext context, {
    required Function(DateTime bedTime, DateTime wakeTime, SleepQuality quality) onAdd,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSleepSheet(onAdd: onAdd),
    );
  }

  @override
  State<AddSleepSheet> createState() => _AddSleepSheetState();
}

class _AddSleepSheetState extends State<AddSleepSheet> {
  late TimeOfDay _bedTime;
  late TimeOfDay _wakeTime;
  SleepQuality _selectedQuality = SleepQuality.good;

  @override
  void initState() {
    super.initState();
    // Default to reasonable bedtime/wake time
    _bedTime = const TimeOfDay(hour: 22, minute: 30);
    _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  }

  Duration _calculateDuration() {
    final now = DateTime.now();
    final bedDateTime = DateTime(
      now.year,
      now.month,
      now.day - 1,
      _bedTime.hour,
      _bedTime.minute,
    );
    var wakeDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );

    // Handle case where wake time is before bed time (next day)
    if (wakeDateTime.isBefore(bedDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }

    return wakeDateTime.difference(bedDateTime);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Future<void> _selectBedTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _bedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _bedTime = time);
    }
  }

  Future<void> _selectWakeTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _wakeTime = time);
    }
  }

  void _handleSave() {
    final now = DateTime.now();
    final bedDateTime = DateTime(
      now.year,
      now.month,
      now.day - 1,
      _bedTime.hour,
      _bedTime.minute,
    );
    var wakeDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );

    // Handle case where wake time is before bed time
    if (wakeDateTime.isBefore(bedDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }

    HapticFeedback.mediumImpact();
    widget.onAdd(bedDateTime, wakeDateTime, _selectedQuality);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final duration = _calculateDuration();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.bedtime,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Log Sleep',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Duration preview
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Sleep Duration',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Time pickers row
                      Row(
                        children: [
                          Expanded(
                            child: _TimePickerCard(
                              icon: Icons.bedtime,
                              label: 'Bedtime',
                              time: _bedTime,
                              onTap: _selectBedTime,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _TimePickerCard(
                              icon: Icons.wb_sunny,
                              label: 'Wake Time',
                              time: _wakeTime,
                              onTap: _selectWakeTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Sleep quality
                      Text(
                        'Sleep Quality',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SleepQuality.values.map((quality) {
                          final isSelected = _selectedQuality == quality;
                          final color = SleepQualityBadge.getQualityColor(quality);
                          final label = SleepQualityBadge.getQualityLabel(quality);
                          final icon = SleepQualityBadge.getQualityIcon(quality);

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedQuality = quality);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: 0.2)
                                    : AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : AppTheme.textTertiary.withValues(alpha: 0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    color: isSelected ? color : AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected ? color : AppTheme.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: AppTheme.textOnPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Save Sleep Log',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimePickerCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePickerCard({
    required this.icon,
    required this.label,
    required this.time,
    required this.onTap,
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(time),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
