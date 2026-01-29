import 'package:assistant/data/mock/models/sleep_record_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  final MockRepository _repository = MockRepository();
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  SleepQuality _selectedQuality = SleepQuality.good;

  void _showAddSleepDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Log Sleep'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bedtime),
                  title: const Text('Bedtime'),
                  trailing: Text(_bedTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _bedTime,
                    );
                    if (time != null) {
                      setDialogState(() => _bedTime = time);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.wb_sunny),
                  title: const Text('Wake Time'),
                  trailing: Text(_wakeTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _wakeTime,
                    );
                    if (time != null) {
                      setDialogState(() => _wakeTime = time);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sleep Quality',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: SleepQuality.values.map((quality) {
                    final isSelected = _selectedQuality == quality;
                    return ChoiceChip(
                      label: Text(_getQualityLabel(quality)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() => _selectedQuality = quality);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final now = DateTime.now();
                final bedDateTime = DateTime(
                  now.year,
                  now.month,
                  now.day - 1,
                  _bedTime.hour,
                  _bedTime.minute,
                );
                final wakeDateTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  _wakeTime.hour,
                  _wakeTime.minute,
                );

                _repository.addSleepRecord(SleepRecordModel(
                  id: '',
                  bedTime: bedDateTime,
                  wakeTime: wakeDateTime,
                  quality: _selectedQuality,
                ));
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _getQualityLabel(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return 'Poor';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.good:
        return 'Good';
      case SleepQuality.excellent:
        return 'Excellent';
    }
  }

  Color _getQualityColor(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return Colors.red;
      case SleepQuality.fair:
        return Colors.orange;
      case SleepQuality.good:
        return Colors.lightGreen;
      case SleepQuality.excellent:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final lastNight = _repository.lastNightSleep;
    final sleepRecords = _repository.sleepRecords;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.secondaryGradient,
          ),
          child: Column(
            children: [
              _buildAppBar(padding),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      children: [
                        _buildLastNightCard(lastNight, padding),
                        SizedBox(height: padding),
                        _buildSleepHistory(sleepRecords, padding),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSleepDialog,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: AppTheme.spacingSM),
          const Expanded(
            child: Text(
              'Sleep',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastNightCard(SleepRecordModel? lastNight, double padding) {
    if (lastNight == null) {
      return Container(
        padding: EdgeInsets.all(padding * 1.5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.bedtime,
              size: 48,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppTheme.spacingSM + AppTheme.spacingXS),
            Text(
              'No sleep data yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            SizedBox(height: AppTheme.spacingSM),
            Text(
              'Tap + to log your sleep',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final hours = lastNight.durationHours;
    final hoursInt = hours.floor();
    final minutes = ((hours - hoursInt) * 60).round();

    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'Last Night',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacingMD),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$hoursInt',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              const Text(
                'h ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                '$minutes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const Text(
                'm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          ),
          SizedBox(height: AppTheme.spacingMD),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMD, vertical: AppTheme.spacingSM),
            decoration: BoxDecoration(
              color: _getQualityColor(lastNight.quality).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_getQualityLabel(lastNight.quality)} Sleep',
              style: TextStyle(
                color: _getQualityColor(lastNight.quality),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacingMD),
          Row(
            children: [
              Expanded(child: _buildTimeInfo(Icons.bedtime, 'Bedtime', _formatTime(lastNight.bedTime))),
              Expanded(child: _buildTimeInfo(Icons.wb_sunny, 'Wake up', _formatTime(lastNight.wakeTime))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(IconData icon, String label, String time) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: AppTheme.spacingXS),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepHistory(List<SleepRecordModel> records, double padding) {
    if (records.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleep History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppTheme.spacingSM + AppTheme.spacingXS),
        ...records.take(7).map((record) {
          final hours = record.durationHours;
          final hoursInt = hours.floor();
          final minutes = ((hours - hoursInt) * 60).round();

          return Container(
            margin: EdgeInsets.only(bottom: AppTheme.spacingSM),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getQualityColor(record.quality),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: AppTheme.spacingSM + AppTheme.spacingXS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(record.wakeTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_formatTime(record.bedTime)} - ${_formatTime(record.wakeTime)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${hoursInt}h ${minutes}m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getQualityLabel(record.quality),
                      style: TextStyle(
                        color: _getQualityColor(record.quality),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
