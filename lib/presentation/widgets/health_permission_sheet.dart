import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/providers/health_sync_provider.dart';

class HealthPermissionSheet extends ConsumerStatefulWidget {
  const HealthPermissionSheet({super.key});

  @override
  ConsumerState<HealthPermissionSheet> createState() =>
      _HealthPermissionSheetState();

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (_) => const HealthPermissionSheet(),
    );
  }
}

class _HealthPermissionSheetState
    extends ConsumerState<HealthPermissionSheet> {
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingLG,
        AppTheme.spacingLG,
        AppTheme.spacingLG,
        MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingLG,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLG),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: const Icon(
              Icons.monitor_heart_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),

          // Title
          const Text(
            'Connect Samsung Health',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),

          // Description
          const Text(
            'Allow access to Health Connect to sync your steps, heart rate, sleep, workouts, and calories from Samsung Health and wearable devices.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),

          // Permission list
          _buildPermissionItem(Icons.directions_walk, 'Steps & Distance'),
          _buildPermissionItem(Icons.favorite_outline, 'Heart Rate'),
          _buildPermissionItem(Icons.bedtime_outlined, 'Sleep Data'),
          _buildPermissionItem(Icons.fitness_center, 'Workouts'),
          _buildPermissionItem(Icons.local_fire_department_outlined, 'Calories Burned'),
          const SizedBox(height: AppTheme.spacingLG),

          // Connect button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRequesting ? null : _requestPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.textOnPrimary,
                disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                elevation: 0,
              ),
              child: _isRequesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Connect Health Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),

          // Skip button
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Not Now',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: AppTheme.spacingSM + 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions() async {
    setState(() => _isRequesting = true);

    final granted =
        await ref.read(healthSyncProvider.notifier).requestPermissions();

    if (mounted) {
      setState(() => _isRequesting = false);
      Navigator.of(context).pop(granted);
    }
  }
}
