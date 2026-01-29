import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/calendar/index.dart';
import 'package:assistant/presentation/pages/calories/index.dart';
import 'package:assistant/presentation/pages/focus_timer/index.dart';
import 'package:assistant/presentation/pages/habits/index.dart';
import 'package:assistant/presentation/pages/heart_rate/index.dart';
import 'package:assistant/presentation/pages/inbox/index.dart';
import 'package:assistant/presentation/pages/meditation/index.dart';
import 'package:assistant/presentation/pages/mood/index.dart';
import 'package:assistant/presentation/pages/screen_time/index.dart';
import 'package:assistant/presentation/pages/sleep/index.dart';
import 'package:assistant/presentation/pages/steps/index.dart';
import 'package:assistant/presentation/pages/todos/index.dart';
import 'package:assistant/presentation/pages/water/index.dart';
import 'package:assistant/presentation/pages/weather/index.dart';
import 'package:assistant/presentation/pages/workout/index.dart';
import 'package:assistant/presentation/utils/navigation_utils.dart';
import 'package:assistant/presentation/widgets/bottom_navigation_bar/custom_bottom_navigation_bar.dart';
import 'package:assistant/presentation/widgets/cards/custom_calendar_events_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_calorie_intake_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_focus_timer_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_general_inbox_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_habits_tracker_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_heart_rate_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_meditation_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_mood_tracker_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_screen_time_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_sleep_duration_tracker_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_steps_tracker_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_todos_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_water_intake_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_weather_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_workout_card.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentPage(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Jarvis',
          ),
        ],
      ),
    );
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const _HomeTab();
      case 1:
        return const _JarvisTab();
      default:
        return const _HomeTab();
    }
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final MockRepository _repository = MockRepository();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double paddingValue = (screenWidth * 0.04).clamp(16.0, 24.0);

    // Get live data from repository
    final todos = _repository.todos;
    final todayWater = _repository.todayWaterIntake;
    final todayCalories = _repository.todayCalories;
    final todayWorkoutMinutes = _repository.todayWorkoutMinutes;
    final todayWorkoutSessions = _repository.todayWorkoutSessions;
    final latestHeartRate = _repository.latestHeartRate;
    final restingHeartRate = _repository.restingHeartRate;
    final todayMood = _repository.todayMood;
    final moodStreak = _repository.moodStreak;
    final todayScreenTime = _repository.todayScreenTime;
    final yesterdayScreenTime = _repository.yesterdayScreenTime;
    final todayMeditationMinutes = _repository.todayMeditationMinutes;
    final meditationStreak = _repository.meditationStreak;
    final habits = _repository.habits;
    final completedHabitsToday = _repository.completedHabitsToday;
    final maxHabitStreak = _repository.maxStreak;
    final unreadMessages = _repository.unreadMessagesCount;
    final messageServices = _repository.messageServices.length;
    final todayEvents = _repository.todayEventsCount;
    final nextEvent = _repository.nextEvent;
    final focusSessionsToday = _repository.todayCompletedSessions;
    final weather = _repository.weather;

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Productivity Section
              CustomTodosCard(
                totalTodos: todos.length,
                completedTodos: _repository.completedTodosCount,
                onTap: () => _navigateTo(const TodosPage()),
                onAddPressed: () => _navigateTo(const TodosPage()),
              ),
              SizedBox(height: paddingValue),
              CustomGeneralInboxCard(
                unreadCount: unreadMessages,
                servicesCount: messageServices,
                onTap: () => _navigateTo(const InboxPage()),
              ),
              SizedBox(height: paddingValue),
              CustomCalendarEventsCard(
                nextEventTitle: nextEvent?.title ?? 'No events',
                nextEventTime: nextEvent != null ? _formatEventTime(nextEvent.startTime) : '',
                eventsToday: todayEvents,
                onTap: () => _navigateTo(const CalendarPage()),
                onAddPressed: () => _navigateTo(const CalendarPage()),
              ),
              SizedBox(height: paddingValue),
              CustomFocusTimerCard(
                isRunning: false,
                remainingMinutes: 25,
                sessionsCompleted: focusSessionsToday,
                onTap: () => _navigateTo(const FocusTimerPage()),
                onStartStopPressed: () => _navigateTo(const FocusTimerPage()),
              ),
              SizedBox(height: paddingValue),
              CustomHabitsTrackerCard(
                completedHabits: completedHabitsToday,
                totalHabits: habits.length,
                streak: maxHabitStreak,
                onTap: () => _navigateTo(const HabitsPage()),
                onAddPressed: () => _navigateTo(const HabitsPage()),
              ),
              SizedBox(height: paddingValue),

              // Health Section
              CustomWeatherCard(
                temperature: weather?.currentTemperature ?? 24,
                condition: _mapWeatherCondition(weather?.currentCondition),
                high: weather?.high ?? 28,
                low: weather?.low ?? 18,
                location: weather?.location ?? 'New York',
                onTap: () => _navigateTo(const WeatherPage()),
              ),
              SizedBox(height: paddingValue),
              CustomWaterIntakeCard(
                currentIntake: todayWater,
                goalIntake: 3000,
                onTap: () => _navigateTo(const WaterPage()),
                onAddPressed: () => _navigateTo(const WaterPage()),
              ),
              SizedBox(height: paddingValue),
              CustomCalorieIntakeCard(
                currentCalories: todayCalories,
                goalCalories: 2000,
                onTap: () => _navigateTo(const CaloriesPage()),
                onAddPressed: () => _navigateTo(const CaloriesPage()),
              ),
              SizedBox(height: paddingValue),
              CustomSleepDurationTrackerCard(
                onTap: () => _navigateTo(const SleepPage()),
              ),
              SizedBox(height: paddingValue),
              CustomStepsTrackerCard(
                onTap: () => _navigateTo(const StepsPage()),
              ),
              SizedBox(height: paddingValue),
              CustomWorkoutCard(
                activeMinutes: todayWorkoutMinutes,
                goalMinutes: 60,
                sessionsToday: todayWorkoutSessions,
                onTap: () => _navigateTo(const WorkoutPage()),
                onStartPressed: () => _navigateTo(const WorkoutPage()),
              ),
              SizedBox(height: paddingValue),
              CustomHeartRateCard(
                currentBpm: latestHeartRate?.bpm ?? 72,
                restingBpm: restingHeartRate,
                onTap: () => _navigateTo(const HeartRatePage()),
              ),
              SizedBox(height: paddingValue),

              // Wellness Section
              CustomMoodTrackerCard(
                currentMood: _mapMoodLevel(todayMood?.mood),
                streak: moodStreak,
                onTap: () => _navigateTo(const MoodPage()),
                onMoodSelected: (mood) => _navigateTo(const MoodPage()),
              ),
              SizedBox(height: paddingValue),
              CustomScreenTimeCard(
                todayMinutes: todayScreenTime?.totalMinutes ?? 225,
                yesterdayMinutes: yesterdayScreenTime?.totalMinutes ?? 260,
                onTap: () => _navigateTo(const ScreenTimePage()),
              ),
              SizedBox(height: paddingValue),
              CustomMeditationCard(
                minutesToday: todayMeditationMinutes,
                streak: meditationStreak,
                onTap: () => _navigateTo(const MeditationPage()),
                onStartPressed: () => _navigateTo(const MeditationPage()),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    NavigationUtils.navigateWithFade(context, page);
  }

  String _formatEventTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  WeatherCondition _mapWeatherCondition(dynamic condition) {
    if (condition == null) return WeatherCondition.sunny;
    switch (condition.toString()) {
      case 'WeatherConditionType.sunny':
        return WeatherCondition.sunny;
      case 'WeatherConditionType.cloudy':
        return WeatherCondition.cloudy;
      case 'WeatherConditionType.rainy':
        return WeatherCondition.rainy;
      case 'WeatherConditionType.stormy':
        return WeatherCondition.stormy;
      case 'WeatherConditionType.snowy':
        return WeatherCondition.snowy;
      case 'WeatherConditionType.partlyCloudy':
        return WeatherCondition.partlyCloudy;
      default:
        return WeatherCondition.sunny;
    }
  }

  MoodType? _mapMoodLevel(dynamic mood) {
    if (mood == null) return null;
    switch (mood.toString()) {
      case 'MoodLevel.great':
        return MoodType.great;
      case 'MoodLevel.good':
        return MoodType.good;
      case 'MoodLevel.okay':
        return MoodType.okay;
      case 'MoodLevel.bad':
        return MoodType.bad;
      case 'MoodLevel.awful':
        return MoodType.awful;
      default:
        return null;
    }
  }
}

class _JarvisTab extends StatelessWidget {
  const _JarvisTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.backgroundColor,
            AppTheme.surfaceColor,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.elevatedShadow,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            Text(
              'Jarvis Assistant',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              'Your AI assistant is ready to help',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
