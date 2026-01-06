import 'package:assistant/presentation/constants/app_theme.dart';
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

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double paddingValue = (screenWidth * 0.04).clamp(16.0, 24.0);

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
                totalTodos: 5,
                completedTodos: 2,
                onTap: () {},
                onAddPressed: () {},
              ),
              SizedBox(height: paddingValue),
              CustomGeneralInboxCard(
                unreadCount: 37,
                servicesCount: 2,
                onTap: () {},
              ),
              SizedBox(height: paddingValue),
              CustomCalendarEventsCard(
                nextEventTitle: 'Team Meeting',
                nextEventTime: '2:00 PM',
                eventsToday: 3,
                onTap: () {},
                onAddPressed: () {},
              ),
              SizedBox(height: paddingValue),
              CustomFocusTimerCard(
                isRunning: false,
                remainingMinutes: 25,
                sessionsCompleted: 2,
                onTap: () {},
                onStartStopPressed: () {},
              ),
              SizedBox(height: paddingValue),
              CustomHabitsTrackerCard(
                completedHabits: 3,
                totalHabits: 5,
                streak: 7,
                onTap: () {},
                onAddPressed: () {},
              ),
              SizedBox(height: paddingValue),

              // Health Section
              CustomWeatherCard(
                temperature: 24,
                condition: WeatherCondition.sunny,
                high: 28,
                low: 18,
                location: 'New York',
                onTap: () {},
              ),
              SizedBox(height: paddingValue),
              CustomWaterIntakeCard(
                currentIntake: 0,
                goalIntake: 3000,
                onTap: () {},
                onAddPressed: () {},
              ),
              SizedBox(height: paddingValue),
              CustomCalorieIntakeCard(
                currentCalories: 1200,
                goalCalories: 2000,
                onTap: () {},
                onAddPressed: () {},
              ),
              SizedBox(height: paddingValue),
              CustomSleepDurationTrackerCard(
                onTap: () {},
              ),
              SizedBox(height: paddingValue),
              CustomStepsTrackerCard(
                onTap: () {},
              ),
              SizedBox(height: paddingValue),
              CustomWorkoutCard(
                activeMinutes: 25,
                goalMinutes: 60,
                sessionsToday: 1,
                onTap: () {},
                onStartPressed: () {},
              ),
              SizedBox(height: paddingValue),
              CustomHeartRateCard(
                currentBpm: 72,
                restingBpm: 65,
                onTap: () {},
              ),
              SizedBox(height: paddingValue),

              // Wellness Section
              CustomMoodTrackerCard(
                currentMood: MoodType.good,
                streak: 5,
                onTap: () {},
                onMoodSelected: (mood) {},
              ),
              SizedBox(height: paddingValue),
              CustomScreenTimeCard(
                todayMinutes: 225,
                yesterdayMinutes: 260,
                onTap: () {},
              ),
              SizedBox(height: paddingValue),
              CustomMeditationCard(
                minutesToday: 10,
                streak: 3,
                onTap: () {},
                onStartPressed: () {},
              ),
              ],
            ),
          ),
        ),
      ),
    );
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
