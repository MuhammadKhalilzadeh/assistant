import 'package:assistant/presentation/constants/ui.dart';
import 'package:flutter/material.dart';

/// A custom bottom navigation bar widget
/// 
/// This widget provides a flexible and reusable bottom navigation bar
/// with customizable items and styling.
class CustomBottomNavigationBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;
  
  /// Callback when an item is tapped
  final Function(int) onTap;
  
  /// List of navigation items
  final List<BottomNavigationBarItem> items;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

