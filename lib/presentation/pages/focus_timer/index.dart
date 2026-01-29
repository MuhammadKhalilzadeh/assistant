import 'dart:async';
import 'package:assistant/data/mock/models/focus_session_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  final MockRepository _repository = MockRepository();
  Timer? _timer;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  String? _currentSessionId;
  int _selectedDuration = 25;

  final List<int> _durations = [15, 25, 30, 45, 60];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _repository.addFocusSession(FocusSessionModel(
      id: _currentSessionId!,
      startTime: DateTime.now(),
      durationMinutes: _selectedDuration,
    ));

    setState(() {
      _isRunning = true;
      _remainingSeconds = _selectedDuration * 60;
    });

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

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedDuration * 60;
      _currentSessionId = null;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    if (_currentSessionId != null) {
      _repository.completeFocusSession(_currentSessionId!);
    }
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedDuration * 60;
      _currentSessionId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Focus session completed!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final sessionsToday = _repository.todayCompletedSessions;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
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
                        _buildDurationSelector(padding),
                        SizedBox(height: padding),
                        _buildControls(padding),
                        SizedBox(height: padding * 2),
                        _buildStatsCard(sessionsToday, padding),
                        SizedBox(height: padding),
                        _buildRecentSessions(padding),
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
              'Focus Timer',
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
    final timerSize = (screenWidth * 0.5).clamp(150.0, 250.0);
    final timerFontSize = (screenWidth * 0.12).clamp(32.0, 48.0);

    return Container(
      padding: EdgeInsets.all(padding * 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: timerSize,
            height: timerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: timerSize * 0.9,
                  height: timerSize * 0.9,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: timerFontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Text(
                      _isRunning ? 'Stay focused!' : 'Ready to focus?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _durations.map((duration) {
                final isSelected = duration == _selectedDuration;
                return Padding(
                  padding: EdgeInsets.only(right: AppTheme.spacingSM),
                  child: GestureDetector(
                    onTap: _isRunning
                        ? null
                        : () {
                            setState(() {
                              _selectedDuration = duration;
                              _remainingSeconds = duration * 60;
                            });
                          },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMD, vertical: AppTheme.spacingSM),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                      child: Text(
                        '${duration}m',
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(double padding) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isRunning || _remainingSeconds != _selectedDuration * 60)
          IconButton(
            onPressed: _resetTimer,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 32),
          ),
        SizedBox(width: AppTheme.spacingMD),
        GestureDetector(
          onTap: _isRunning ? _pauseTimer : _startTimer,
          child: Container(
            width: 80,
            height: 80,
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
              color: AppTheme.primaryColor,
              size: 40,
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingXXL),
      ],
    );
  }

  Widget _buildStatsCard(int sessionsToday, double padding) {
    final totalMinutes = sessionsToday * 25;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem(Icons.check_circle, sessionsToday.toString(), 'Sessions')),
          Expanded(child: _buildStatItem(Icons.timer, '${totalMinutes}m', 'Focus Time')),
          Expanded(child: _buildStatItem(Icons.local_fire_department, '${sessionsToday * 2}', 'Points')),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
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

  Widget _buildRecentSessions(double padding) {
    final sessions = _repository.focusSessions.where((s) => s.isCompleted).take(5).toList();

    if (sessions.isEmpty) {
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
        ...sessions.map((session) => Container(
          margin: EdgeInsets.only(bottom: AppTheme.spacingSM),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: AppTheme.spacingSM + AppTheme.spacingXS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.task ?? 'Focus Session',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${session.durationMinutes} minutes',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatTime(session.startTime),
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

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
