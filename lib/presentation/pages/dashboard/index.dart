import 'package:assistant/presentation/widgets/bottom_navigation_bar/custom_bottom_navigation_bar.dart';
import 'package:assistant/presentation/widgets/cards/custom_general_inbox_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_sleep_duration_tracker_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_steps_tracker_card.dart';
import 'package:assistant/presentation/widgets/cards/custom_water_intake_card.dart';
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
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomGeneralInboxCard(
                unreadCount: 37,
                servicesCount: 2,
                onTap: () {
                  // Navigate to inbox (future)
                },
              ),
              SizedBox(height: paddingValue),
              CustomWaterIntakeCard(
                currentIntake: 0,
                goalIntake: 3000,
                onTap: () {
                  // Navigate to water intake details (future)
                },
                onAddPressed: () {
                  // Add water intake (future)
                },
              ),
              SizedBox(height: paddingValue),
              CustomSleepDurationTrackerCard(
                onTap: () {
                  // Navigate to sleep details (future)
                },
              ),
              SizedBox(height: paddingValue),
              CustomStepsTrackerCard(
                onTap: () {
                  // Navigate to steps details (future)
                },
              ),
            ],
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
    return const Center();
  }
}