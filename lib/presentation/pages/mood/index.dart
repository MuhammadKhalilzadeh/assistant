import 'package:assistant/data/mock/models/mood_entry_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  final MockRepository _repository = MockRepository();
  final TextEditingController _notesController = TextEditingController();
  MoodLevel? _selectedMood;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  IconData _getMoodIcon(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return Icons.sentiment_very_satisfied;
      case MoodLevel.good:
        return Icons.sentiment_satisfied;
      case MoodLevel.okay:
        return Icons.sentiment_neutral;
      case MoodLevel.bad:
        return Icons.sentiment_dissatisfied;
      case MoodLevel.awful:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  Color _getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return Colors.green;
      case MoodLevel.good:
        return Colors.lightGreen;
      case MoodLevel.okay:
        return Colors.amber;
      case MoodLevel.bad:
        return Colors.orange;
      case MoodLevel.awful:
        return Colors.red;
    }
  }

  void _logMood(MoodLevel mood) {
    setState(() => _selectedMood = mood);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note (Optional)'),
        content: TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: 'How are you feeling?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _notesController.clear();
              Navigator.pop(context);
            },
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () {
              _repository.addMoodEntry(MoodEntryModel(
                id: '',
                mood: mood,
                recordedAt: DateTime.now(),
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              ));
              _notesController.clear();
              Navigator.pop(context);
              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mood logged!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      if (_notesController.text.isEmpty && _selectedMood != null) {
        _repository.addMoodEntry(MoodEntryModel(
          id: '',
          mood: mood,
          recordedAt: DateTime.now(),
        ));
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final todayMood = _repository.todayMood;
    final streak = _repository.moodStreak;
    final entries = _repository.moodEntries;

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
                        _buildMoodSelector(todayMood, padding),
                        SizedBox(height: padding),
                        _buildStreakCard(streak, padding),
                        SizedBox(height: padding),
                        _buildMoodHistory(entries, padding),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          const SizedBox(width: 8),
          const Text(
            'Mood',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(MoodEntryModel? todayMood, double padding) {
    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            todayMood != null ? 'Today you felt' : 'How are you feeling?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (todayMood != null) ...[
            const SizedBox(height: 16),
            Icon(
              _getMoodIcon(todayMood.mood),
              color: _getMoodColor(todayMood.mood),
              size: 64,
            ),
            const SizedBox(height: 8),
            Text(
              todayMood.moodLabel,
              style: TextStyle(
                color: _getMoodColor(todayMood.mood),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (todayMood.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                '"${todayMood.notes}"',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            Text(
              'Update your mood',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MoodLevel.values.map((mood) {
              final isSelected = todayMood?.mood == mood;
              return GestureDetector(
                onTap: () => _logMood(mood),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _getMoodColor(mood).withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: _getMoodColor(mood), width: 2)
                            : null,
                      ),
                      child: Icon(
                        _getMoodIcon(mood),
                        color: isSelected ? _getMoodColor(mood) : Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mood.name[0].toUpperCase() + mood.name.substring(1),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int streak, double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mood Streak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'You\'ve logged your mood $streak days in a row!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$streak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodHistory(List<MoodEntryModel> entries, double padding) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...entries.take(10).map((entry) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMoodColor(entry.mood).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getMoodIcon(entry.mood),
                  color: _getMoodColor(entry.mood),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.moodLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (entry.notes != null)
                      Text(
                        entry.notes!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                _formatDate(entry.recordedAt),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';

    return '${date.month}/${date.day}';
  }
}
