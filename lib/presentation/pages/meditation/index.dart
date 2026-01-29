import 'dart:async';
import 'package:assistant/data/mock/models/meditation_session_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage>
    with SingleTickerProviderStateMixin {
  final MockRepository _repository = MockRepository();
  Timer? _timer;
  int _remainingSeconds = 5 * 60;
  bool _isRunning = false;
  int _selectedDuration = 5;
  MeditationType _selectedType = MeditationType.breathing;
  late AnimationController _breathController;

  final List<int> _durations = [3, 5, 10, 15, 20];

  final Map<MeditationType, IconData> _typeIcons = {
    MeditationType.breathing: Icons.air,
    MeditationType.guided: Icons.headphones,
    MeditationType.unguided: Icons.self_improvement,
    MeditationType.sleep: Icons.bedtime,
    MeditationType.focus: Icons.center_focus_strong,
  };

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isRunning = true;
      _remainingSeconds = _selectedDuration * 60;
    });

    _breathController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseSession() {
    _timer?.cancel();
    _breathController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    _breathController.stop();

    _repository.addMeditationSession(MeditationSessionModel(
      id: '',
      type: _selectedType,
      startTime: DateTime.now().subtract(Duration(minutes: _selectedDuration)),
      durationMinutes: _selectedDuration,
      isCompleted: true,
    ));

    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedDuration * 60;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meditation session completed!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  String _getTypeName(MeditationType type) {
    switch (type) {
      case MeditationType.breathing:
        return 'Breathing';
      case MeditationType.guided:
        return 'Guided';
      case MeditationType.unguided:
        return 'Unguided';
      case MeditationType.sleep:
        return 'Sleep';
      case MeditationType.focus:
        return 'Focus';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final todayMinutes = _repository.todayMeditationMinutes;
    final streak = _repository.meditationStreak;
    final sessions = _repository.meditationSessions;

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
                        _buildTimerDisplay(screenWidth, padding),
                        SizedBox(height: padding),
                        if (!_isRunning) ...[
                          _buildTypeSelector(padding),
                          SizedBox(height: padding),
                          _buildDurationSelector(padding),
                          SizedBox(height: padding),
                        ],
                        _buildStatsCard(todayMinutes, streak, padding),
                        SizedBox(height: padding),
                        if (!_isRunning) _buildRecentSessions(sessions, padding),
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
          SizedBox(width: AppTheme.spacingSM),
          const Expanded(
            child: Text(
              'Meditation',
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

  Widget _buildTimerDisplay(double screenWidth, double padding) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final progress = 1 - (_remainingSeconds / (_selectedDuration * 60));

    return Container(
      padding: EdgeInsets.all(padding * 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          if (_isRunning && _selectedType == MeditationType.breathing)
            AnimatedBuilder(
              animation: _breathController,
              builder: (context, child) {
                final scale = 0.8 + (_breathController.value * 0.4);
                final breathSize = (screenWidth * 0.3).clamp(80.0, 120.0);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: breathSize,
                    height: breathSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(
                        _breathController.value < 0.5 ? 'Breathe In' : 'Breathe Out',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            SizedBox(
              width: (screenWidth * 0.4).clamp(120.0, 200.0),
              height: (screenWidth * 0.4).clamp(120.0, 200.0),
              child: CustomPaint(
                painter: _MeditationProgressPainter(progress),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _typeIcons[_selectedType],
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: AppTheme.spacingSM),
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(height: AppTheme.spacingLG),
          GestureDetector(
            onTap: _isRunning ? _pauseSession : _startSession,
            child: Container(
              width: (screenWidth * 0.18).clamp(56.0, 80.0),
              height: (screenWidth * 0.18).clamp(56.0, 80.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isRunning ? Icons.pause : Icons.play_arrow,
                color: AppTheme.accentColor,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacingSM + AppTheme.spacingXS),
          Wrap(
            spacing: AppTheme.spacingSM,
            runSpacing: AppTheme.spacingSM,
            children: MeditationType.values.map((type) {
              final isSelected = type == _selectedType;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSM + AppTheme.spacingXS, vertical: AppTheme.spacingSM),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _typeIcons[type],
                        color: isSelected ? AppTheme.accentColor : Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: AppTheme.spacingXS),
                      Text(
                        _getTypeName(type),
                        style: TextStyle(
                          color: isSelected ? AppTheme.accentColor : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Duration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacingSM + AppTheme.spacingXS),
          Wrap(
            spacing: AppTheme.spacingSM,
            runSpacing: AppTheme.spacingSM,
            alignment: WrapAlignment.center,
            children: _durations.map((duration) {
              final isSelected = duration == _selectedDuration;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDuration = duration;
                  _remainingSeconds = duration * 60;
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMD, vertical: AppTheme.spacingSM),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${duration}m',
                    style: TextStyle(
                      color: isSelected ? AppTheme.accentColor : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int todayMinutes, int streak, double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem(Icons.timer, '${todayMinutes}m', 'Today')),
          Expanded(child: _buildStatItem(Icons.local_fire_department, '$streak', 'Streak')),
          Expanded(child: _buildStatItem(Icons.self_improvement, '${todayMinutes ~/ 5}', 'Sessions')),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: AppTheme.spacingSM),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
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

  Widget _buildRecentSessions(List<MeditationSessionModel> sessions, double padding) {
    final completedSessions = sessions.where((s) => s.isCompleted).take(5).toList();

    if (completedSessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Sessions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppTheme.spacingSM + AppTheme.spacingXS),
        ...completedSessions.map((session) => Container(
          margin: EdgeInsets.only(bottom: AppTheme.spacingSM),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacingSM + 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _typeIcons[session.type],
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: AppTheme.spacingSM + AppTheme.spacingXS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeName(session.type),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDate(session.startTime),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${session.durationMinutes}m',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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

class _MeditationProgressPainter extends CustomPainter {
  final double progress;

  _MeditationProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
