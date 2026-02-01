import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// App bar for the Screen Time page with back button, title, and settings
class ScreenTimeAppBar extends StatelessWidget {
  final double padding;
  final double progress;
  final bool isOverLimit;
  final VoidCallback? onSettingsTap;

  const ScreenTimeAppBar({
    super.key,
    required this.padding,
    required this.progress,
    this.isOverLimit = false,
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
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Text(
              'Screen Time',
              style: TextStyle(
                color: AppTheme.textPrimary,
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
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverLimit
                        ? AppTheme.errorColor
                        : progress >= 0.8
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                  ),
                ),
              ),
              // Settings button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: IconButton(
                  onPressed: onSettingsTap,
                  icon: Icon(
                    Icons.settings_outlined,
                    color: AppTheme.textPrimary,
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
