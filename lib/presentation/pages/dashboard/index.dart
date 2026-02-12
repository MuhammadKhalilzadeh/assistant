import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/data/models/calorie_entry_model.dart';
import 'package:assistant/data/models/habit_stats.dart';
import 'package:assistant/data/models/heart_rate_model.dart';
import 'package:assistant/data/models/meditation_session_model.dart';
import 'package:assistant/data/models/mood_entry_model.dart';
import 'package:assistant/data/models/sleep_record_model.dart';
import 'package:assistant/data/models/step_record_model.dart';
import 'package:assistant/data/models/todo_stats.dart';
import 'package:assistant/data/models/water_log_model.dart';
import 'package:assistant/data/models/workout_session_model.dart';
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
import 'package:assistant/providers/calories_provider.dart';
import 'package:assistant/providers/habit_provider.dart';
import 'package:assistant/providers/heart_rate_provider.dart';
import 'package:assistant/providers/meditation_provider.dart';
import 'package:assistant/providers/mood_provider.dart';
import 'package:assistant/providers/sleep_provider.dart';
import 'package:assistant/providers/steps_provider.dart';
import 'package:assistant/providers/todo_provider.dart';
import 'package:assistant/providers/water_provider.dart';
import 'package:assistant/providers/calendar_provider.dart';
import 'package:assistant/providers/workout_provider.dart';
import 'package:assistant/providers/focus_timer_provider.dart';
import 'package:assistant/providers/weather_provider.dart';
import 'package:assistant/data/models/focus_session_model.dart';
import 'package:assistant/data/models/calendar_event.dart';
import 'package:assistant/data/models/weather_forecast_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double paddingValue = (screenWidth * 0.04).clamp(16.0, 24.0);

    // Watch real providers for 10 backend-connected features
    final todoStats = ref.watch(todoStatsProvider).valueOrNull ?? TodoStats.empty();
    final habitStats = ref.watch(habitStatsProvider).valueOrNull ?? HabitStats.empty();
    final waterStats = ref.watch(waterStatsProvider).valueOrNull ?? WaterStats.empty();
    final nutritionStats = ref.watch(nutritionStatsProvider).valueOrNull ?? NutritionStats.empty();
    final heartRateStats = ref.watch(heartRateStatsProvider).valueOrNull ?? HeartRateStats.empty();
    final stepsStats = ref.watch(stepsStatsProvider).valueOrNull ?? StepsStats.empty();
    final sleepStats = ref.watch(sleepStatsProvider).valueOrNull ?? SleepStats.empty();
    final moodStats = ref.watch(moodStatsProvider).valueOrNull ?? MoodStats.empty();
    final meditationStats = ref.watch(meditationStatsProvider).valueOrNull ?? MeditationStats.empty();
    final workoutStats = ref.watch(workoutStatsProvider).valueOrNull ?? WorkoutStats.empty();
    final workoutGoal = ref.watch(workoutGoalProvider).valueOrNull;
    final calendarStats = ref.watch(calendarStatsProvider).valueOrNull ?? CalendarStats.empty();
    final focusTimerStats = ref.watch(focusTimerStatsProvider).valueOrNull ?? FocusTimerStats.empty();

    // Real weather data from provider
    final weather = ref.watch(weatherProvider).valueOrNull;

    // Mock data for 2 UI-only features (no backend yet)
    final repository = MockRepository();
    final unreadMessages = repository.unreadMessagesCount;
    final messageServices = repository.messageServices.length;
    final todayScreenTime = repository.todayScreenTime;
    final yesterdayScreenTime = repository.yesterdayScreenTime;

    void navigateTo(Widget page) {
      NavigationUtils.navigateWithFade(context, page);
    }

    return SafeArea(
      child: Container(
        color: AppTheme.backgroundColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Productivity Section
              CustomTodosCard(
                totalTodos: todoStats.total,
                completedTodos: todoStats.completed,
                onTap: () => navigateTo(const TodosPage()),
                onAddPressed: () => navigateTo(const TodosPage()),
              ),
              SizedBox(height: paddingValue),
              CustomGeneralInboxCard(
                unreadCount: unreadMessages,
                servicesCount: messageServices,
                onTap: () => navigateTo(const InboxPage()),
              ),
              SizedBox(height: paddingValue),
              CustomCalendarEventsCard(
                nextEventTitle: calendarStats.nextEventTitle ?? 'No events',
                nextEventTime: calendarStats.nextEventTime != null
                    ? _formatEventTime(calendarStats.nextEventTime!)
                    : '',
                eventsToday: calendarStats.todayEventsCount,
                onTap: () => navigateTo(const CalendarPage()),
                onAddPressed: () => navigateTo(const CalendarPage()),
              ),
              SizedBox(height: paddingValue),
              CustomFocusTimerCard(
                isRunning: false,
                remainingMinutes: 25,
                sessionsCompleted: focusTimerStats.todaySessions,
                onTap: () => navigateTo(const FocusTimerPage()),
                onStartStopPressed: () => navigateTo(const FocusTimerPage()),
              ),
              SizedBox(height: paddingValue),
              CustomHabitsTrackerCard(
                completedHabits: habitStats.completedToday,
                totalHabits: habitStats.totalHabits,
                streak: habitStats.maxBestStreak,
                onTap: () => navigateTo(const HabitsPage()),
                onAddPressed: () => navigateTo(const HabitsPage()),
              ),
              SizedBox(height: paddingValue),

              // Health Section
              CustomWeatherCard(
                temperature: weather?.currentTemperature ?? 24,
                condition: _mapWeatherCondition(weather?.currentCondition),
                high: weather?.high ?? 28,
                low: weather?.low ?? 18,
                location: weather?.location ?? 'New York',
                onTap: () => navigateTo(const WeatherPage()),
              ),
              SizedBox(height: paddingValue),
              CustomWaterIntakeCard(
                currentIntake: waterStats.todayIntakeMl,
                goalIntake: waterStats.dailyGoalMl,
                onTap: () => navigateTo(const WaterPage()),
                onAddPressed: () => navigateTo(const WaterPage()),
              ),
              SizedBox(height: paddingValue),
              CustomCalorieIntakeCard(
                currentCalories: nutritionStats.todayCalories,
                goalCalories: nutritionStats.dailyCalorieGoal,
                onTap: () => navigateTo(const CaloriesPage()),
                onAddPressed: () => navigateTo(const CaloriesPage()),
              ),
              SizedBox(height: paddingValue),
              CustomSleepDurationTrackerCard(
                duration: '${sleepStats.weeklyAverageHours.toStringAsFixed(1)}h avg',
                timeRange: '${sleepStats.averageBedTime ?? '--:--'} - ${sleepStats.averageWakeTime ?? '--:--'}',
                onTap: () => navigateTo(const SleepPage()),
              ),
              SizedBox(height: paddingValue),
              CustomStepsTrackerCard(
                currentSteps: stepsStats.todaySteps,
                goalSteps: stepsStats.dailyGoal,
                onTap: () => navigateTo(const StepsPage()),
              ),
              SizedBox(height: paddingValue),
              CustomWorkoutCard(
                activeMinutes: workoutStats.weeklyMinutes,
                goalMinutes: workoutGoal?.weeklyMinutesGoal ?? 150,
                sessionsToday: workoutStats.weeklySessions,
                onTap: () => navigateTo(const WorkoutPage()),
                onStartPressed: () => navigateTo(const WorkoutPage()),
              ),
              SizedBox(height: paddingValue),
              CustomHeartRateCard(
                currentBpm: heartRateStats.maxBpm,
                restingBpm: heartRateStats.averageRestingBpm.round(),
                onTap: () => navigateTo(const HeartRatePage()),
              ),
              SizedBox(height: paddingValue),

              // Wellness Section
              CustomMoodTrackerCard(
                currentMood: _mapMoodScore(moodStats.weeklyAverageMood),
                streak: moodStats.currentStreak,
                onTap: () => navigateTo(const MoodPage()),
                onMoodSelected: (mood) => navigateTo(const MoodPage()),
              ),
              SizedBox(height: paddingValue),
              CustomScreenTimeCard(
                todayMinutes: todayScreenTime?.totalMinutes ?? 225,
                yesterdayMinutes: yesterdayScreenTime?.totalMinutes ?? 260,
                onTap: () => navigateTo(const ScreenTimePage()),
              ),
              SizedBox(height: paddingValue),
              CustomMeditationCard(
                minutesToday: meditationStats.todayMinutes,
                streak: meditationStats.currentStreak,
                onTap: () => navigateTo(const MeditationPage()),
                onStartPressed: () => navigateTo(const MeditationPage()),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatEventTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  WeatherCondition _mapWeatherCondition(WeatherConditionType? condition) {
    if (condition == null) return WeatherCondition.sunny;
    switch (condition) {
      case WeatherConditionType.sunny:
        return WeatherCondition.sunny;
      case WeatherConditionType.cloudy:
        return WeatherCondition.cloudy;
      case WeatherConditionType.rainy:
        return WeatherCondition.rainy;
      case WeatherConditionType.stormy:
        return WeatherCondition.stormy;
      case WeatherConditionType.snowy:
        return WeatherCondition.snowy;
      case WeatherConditionType.partlyCloudy:
        return WeatherCondition.partlyCloudy;
    }
  }

  MoodType? _mapMoodScore(double score) {
    if (score <= 0) return null;
    if (score >= 4.5) return MoodType.great;
    if (score >= 3.5) return MoodType.good;
    if (score >= 2.5) return MoodType.okay;
    if (score >= 1.5) return MoodType.bad;
    return MoodType.awful;
  }
}

class _JarvisTab extends StatelessWidget {
  const _JarvisTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
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
