import 'package:flutter/material.dart';

/// App bar for the Water Intake page with back button, title, and settings
class WaterAppBar extends StatelessWidget {
  final double padding;
  final double progress;
  final VoidCallback? onSettingsTap;

  const WaterAppBar({
    super.key,
    required this.padding,
    required this.progress,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          const Expanded(
            child: Text(
              'Water Intake',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Settings button with progress ring
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring around settings icon
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? const Color(0xFF10B981) // Green when goal met
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
              // Settings button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: IconButton(
                  onPressed: onSettingsTap,
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
