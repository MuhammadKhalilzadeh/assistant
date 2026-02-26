import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/providers/auth_provider.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/widgets/dialogs/sign_out_confirmation_dialog.dart';

class AccountSheet extends ConsumerWidget {
  const AccountSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (_) => const AccountSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLG,
        vertical: AppTheme.spacingLG,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLG),

          // User info row
          Row(
            children: [
              // Avatar
              _buildAvatar(user?.photoUrl, user?.displayName, user?.email),
              const SizedBox(width: AppTheme.spacingMD),
              // Name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLG),

          // Gmail connection status
          _buildGmailRow(context, ref, authState.isGmailConnected),
          const SizedBox(height: AppTheme.spacingMD),

          // Sign Out button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _handleSignOut(context, ref),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.cardColor,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl, String? displayName, String? email) {
    final firstLetter =
        (displayName ?? email ?? 'U').substring(0, 1).toUpperCase();

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppTheme.cardColor,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      child: photoUrl == null
          ? Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            )
          : null,
    );
  }

  Widget _buildGmailRow(
    BuildContext context,
    WidgetRef ref,
    bool isConnected,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingMD,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_outlined, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacingSM),
          const Expanded(
            child: Text(
              'Gmail',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (isConnected)
            const Text(
              'Connected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.successColor,
              ),
            )
          else
            _buildConnectGmailButton(ref),
        ],
      ),
    );
  }

  Widget _buildConnectGmailButton(WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(authProvider.notifier).connectGmail(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: const Text(
          'Connect Gmail',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textOnPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const SignOutConfirmationDialog(),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(); // Close the bottom sheet
      await ref.read(authProvider.notifier).signOut();
    }
  }
}
