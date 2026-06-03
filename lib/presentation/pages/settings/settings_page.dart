import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/providers/auth_provider.dart';
import 'package:assistant/providers/settings_provider.dart';
import 'package:assistant/providers/health_sync_provider.dart';
import 'package:assistant/presentation/widgets/dialogs/sign_out_confirmation_dialog.dart';
import 'package:assistant/presentation/widgets/health_permission_sheet.dart';
import 'package:assistant/presentation/pages/insights/index.dart';
import 'package:assistant/presentation/pages/weekly_report/index.dart';
import 'package:assistant/data/services/health_connect_service.dart';
import 'package:assistant/data/services/notifications_api_service.dart';
import 'package:assistant/presentation/pages/agent/goal_suggestions_page.dart';
import 'package:assistant/presentation/pages/agent/weekly_plan_page.dart';
import 'package:assistant/presentation/pages/agent/agent_settings_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isEditingNickname = false;
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final apiKeys = ref.watch(apiKeysProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(user),
            const SizedBox(height: AppTheme.spacingLG),

            // AI API Keys Section
            _buildApiKeysSection(apiKeys),
            const SizedBox(height: AppTheme.spacingLG),

            // Connected Services Section
            _buildConnectedServicesSection(authState.isGmailConnected),
            const SizedBox(height: AppTheme.spacingLG),

            // Health Connect Section
            _buildHealthConnectSection(),
            const SizedBox(height: AppTheme.spacingLG),

            // AI Intelligence Section
            _buildAIIntelligenceSection(),
            const SizedBox(height: AppTheme.spacingLG),

            // About Section
            _buildAboutSection(),
            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }

  // ─── Profile Section ───────────────────────────────────────────────

  Widget _buildProfileSection(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor,
            backgroundImage: user?.photoUrl != null
                ? NetworkImage(user!.photoUrl!)
                : null,
            child: user?.photoUrl == null
                ? Text(
                    (user?.greeting ?? '?')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppTheme.spacingMD),

          // Name & email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Editable nickname row
                _isEditingNickname
                    ? _buildNicknameEditor(user)
                    : GestureDetector(
                        onTap: () {
                          _nicknameController.text =
                              user?.nickname ?? user?.displayName ?? '';
                          setState(() => _isEditingNickname = true);
                        },
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                user?.greeting ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingXS),
                            const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: AppTheme.textTertiary,
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameEditor(dynamic user) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              controller: _nicknameController,
              autofocus: true,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSM,
                  vertical: 0,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                  borderSide: const BorderSide(color: AppTheme.cardBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                  borderSide: const BorderSide(color: AppTheme.cardBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                  borderSide: const BorderSide(
                    color: AppTheme.activeBorderColor,
                    width: AppTheme.activeBorderWidth,
                  ),
                ),
              ),
              onSubmitted: (_) => _saveNickname(),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingXS),
        IconButton(
          icon: const Icon(Icons.check, color: AppTheme.successColor, size: 20),
          onPressed: _saveNickname,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textTertiary, size: 20),
          onPressed: () => setState(() => _isEditingNickname = false),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Future<void> _saveNickname() async {
    final text = _nicknameController.text.trim();
    if (text.isEmpty) return;

    final success =
        await ref.read(authProvider.notifier).updateNickname(text);

    if (mounted) {
      setState(() => _isEditingNickname = false);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update nickname'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // ─── AI API Keys Section ───────────────────────────────────────────

  Widget _buildApiKeysSection(Map<String, String> apiKeys) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppTheme.spacingMD,
              AppTheme.spacingMD,
              AppTheme.spacingMD,
              AppTheme.spacingSM,
            ),
            child: Text(
              'AI API Keys',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ...aiProviders.map((provider) {
            final maskedKey = apiKeys[provider];
            final isConfigured = maskedKey != null && maskedKey.isNotEmpty;
            return _buildApiKeyTile(
              title: aiProviderNames[provider] ?? provider,
              maskedKey: maskedKey,
              isConfigured: isConfigured,
              onTap: () => _showApiKeySheet(provider, isConfigured),
            );
          }),
          const SizedBox(height: AppTheme.spacingSM),
        ],
      ),
    );
  }

  Widget _buildApiKeyTile({
    required String title,
    required String? maskedKey,
    required bool isConfigured,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMD,
          vertical: AppTheme.spacingSM + 4,
        ),
        child: Row(
          children: [
            Icon(
              Icons.key_outlined,
              size: 20,
              color: isConfigured
                  ? AppTheme.primaryColor
                  : AppTheme.textTertiary,
            ),
            const SizedBox(width: AppTheme.spacingSM + 4),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Text(
              isConfigured ? maskedKey! : 'Not configured',
              style: TextStyle(
                fontSize: 13,
                color: isConfigured
                    ? AppTheme.textSecondary
                    : AppTheme.textTertiary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingXS),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _showApiKeySheet(String provider, bool isConfigured) {
    final controller = TextEditingController();
    bool obscured = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppTheme.spacingLG,
                AppTheme.spacingLG,
                AppTheme.spacingLG,
                MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingLG,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // Title
                  Text(
                    '${aiProviderNames[provider]} API Key',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),

                  // Key input
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                      border: Border.all(color: AppTheme.cardBorderColor),
                    ),
                    child: TextField(
                      controller: controller,
                      obscureText: obscured,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your API key',
                        hintStyle: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMD,
                          vertical: AppTheme.spacingMD,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppTheme.textTertiary,
                            size: 20,
                          ),
                          onPressed: () {
                            setSheetState(() => obscured = !obscured);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final key = controller.text.trim();
                        if (key.isEmpty) return;
                        await ref
                            .read(apiKeysProvider.notifier)
                            .saveKey(provider, key);
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.textOnPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Delete button (only if already configured)
                  if (isConfigured) ...[
                    const SizedBox(height: AppTheme.spacingSM),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          await ref
                              .read(apiKeysProvider.notifier)
                              .deleteKey(provider);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                        style: TextButton.styleFrom(
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
                          'Delete Key',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Connected Services Section ────────────────────────────────────

  Widget _buildConnectedServicesSection(bool isGmailConnected) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppTheme.spacingMD,
              AppTheme.spacingMD,
              AppTheme.spacingMD,
              AppTheme.spacingSM,
            ),
            child: Text(
              'Connected Services',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMD,
              vertical: AppTheme.spacingSM + 4,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingSM + 4),
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
                if (isGmailConnected)
                  const Text(
                    'Connected',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.successColor,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () =>
                        ref.read(authProvider.notifier).connectGmail(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMedium,
                        ),
                      ),
                      child: const Text(
                        'Connect',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
        ],
      ),
    );
  }

  // ─── Health Connect Section ────────────────────────────────────────

  Widget _buildHealthConnectSection() {
    final healthSync = ref.watch(healthSyncProvider);

    return healthSync.when(
      data: (syncState) => Container(
        decoration: AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppTheme.spacingMD,
                AppTheme.spacingMD,
                AppTheme.spacingMD,
                AppTheme.spacingSM,
              ),
              child: Text(
                'Health Connect',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            // Connection status / toggle
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMD,
                vertical: AppTheme.spacingSM + 4,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monitor_heart_outlined,
                    size: 20,
                    color: syncState.hasPermissions
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingSM + 4),
                  const Expanded(
                    child: Text(
                      'Samsung Health',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (!syncState.isAvailable)
                    const Text(
                      'Not available',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textTertiary,
                      ),
                    )
                  else if (!syncState.hasPermissions)
                    GestureDetector(
                      onTap: () => HealthPermissionSheet.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                        ),
                        child: const Text(
                          'Connect',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textOnPrimary,
                          ),
                        ),
                      ),
                    )
                  else
                    Switch(
                      value: syncState.isEnabled,
                      activeThumbColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        ref
                            .read(healthSyncProvider.notifier)
                            .setEnabled(value);
                      },
                    ),
                ],
              ),
            ),

            // Last sync time
            if (syncState.hasPermissions && syncState.isEnabled) ...[
              const Divider(
                color: AppTheme.dividerColor,
                height: 1,
                indent: AppTheme.spacingMD,
                endIndent: AppTheme.spacingMD,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMD,
                  vertical: AppTheme.spacingSM + 4,
                ),
                child: Row(
                  children: [
                    Icon(
                      syncState.status == HealthSyncStatus.syncing
                          ? Icons.sync
                          : Icons.access_time,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.spacingSM + 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            syncState.status == HealthSyncStatus.syncing
                                ? 'Syncing...'
                                : 'Last synced',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (syncState.lastSyncTime != null)
                            Text(
                              _formatSyncTime(syncState.lastSyncTime!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Sync now button
                    if (syncState.status != HealthSyncStatus.syncing)
                      GestureDetector(
                        onTap: () =>
                            ref.read(healthSyncProvider.notifier).syncRecent(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.cardBorderColor),
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusSmall,
                            ),
                          ),
                          child: const Text(
                            'Sync Now',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Error message
              if (syncState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacingMD,
                    0,
                    AppTheme.spacingMD,
                    AppTheme.spacingSM,
                  ),
                  child: Text(
                    syncState.errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.errorColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            const SizedBox(height: AppTheme.spacingSM),
          ],
        ),
      ),
      loading: () => Container(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        decoration: AppTheme.cardDecoration(),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppTheme.spacingSM + 4),
            Text(
              'Checking Health Connect...',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ─── AI Intelligence Section ────────────────────────────────────────

  Widget _buildAIIntelligenceSection() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spacingMD,
              right: AppTheme.spacingMD,
              top: AppTheme.spacingSM + 4,
              bottom: AppTheme.spacingSM,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology_outlined,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: AppTheme.spacingSM + 4),
                const Text(
                  'AI Intelligence',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.cardBorderColor),

          // View Insights
          _buildSettingsTile(
            icon: Icons.insights_outlined,
            title: 'AI Insights',
            subtitle: 'Correlations, trends, and anomalies',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InsightsPage()),
            ),
          ),
          const Divider(height: 1, indent: 52, color: AppTheme.cardBorderColor),

          // Weekly Report
          _buildSettingsTile(
            icon: Icons.assessment_outlined,
            title: 'Weekly Report',
            subtitle: 'Generate a comprehensive progress report',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WeeklyReportPage()),
            ),
          ),
          const Divider(height: 1, indent: 52, color: AppTheme.cardBorderColor),

          // Morning Briefing
          _buildSettingsTile(
            icon: Icons.wb_sunny_outlined,
            title: 'Morning Briefing',
            subtitle: 'Request an on-demand daily briefing',
            onTap: () async {
              try {
                await NotificationsApiService().requestMorningBriefing();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Morning briefing sent to your inbox'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
          const Divider(height: 1, indent: 52, color: AppTheme.cardBorderColor),

          // Weekly Plan
          _buildSettingsTile(
            icon: Icons.calendar_month_outlined,
            title: 'Weekly Plan',
            subtitle: 'AI-generated weekly wellness plan',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WeeklyPlanPage()),
            ),
          ),
          const Divider(height: 1, indent: 52, color: AppTheme.cardBorderColor),

          // Goal Suggestions
          _buildSettingsTile(
            icon: Icons.track_changes_outlined,
            title: 'Goal Suggestions',
            subtitle: 'Review AI-recommended goal adjustments',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GoalSuggestionsPage()),
            ),
          ),
          const Divider(height: 1, indent: 52, color: AppTheme.cardBorderColor),

          // Agent Settings
          _buildSettingsTile(
            icon: Icons.tune_outlined,
            title: 'Agent Autonomy',
            subtitle: 'Configure how autonomous Jarvis can be',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AgentSettingsPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMD,
          vertical: AppTheme.spacingSM + 4,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: AppTheme.spacingSM + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // ─── About Section ─────────────────────────────────────────────────

  Widget _buildAboutSection() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          // App version
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMD,
              vertical: AppTheme.spacingSM + 4,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingSM + 4),
                const Expanded(
                  child: Text(
                    'App Version',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: AppTheme.dividerColor,
            height: 1,
            indent: AppTheme.spacingMD,
            endIndent: AppTheme.spacingMD,
          ),

          // Sign Out
          InkWell(
            onTap: () => _handleSignOut(),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppTheme.borderRadiusCard),
              bottomRight: Radius.circular(AppTheme.borderRadiusCard),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMD,
                vertical: AppTheme.spacingSM + 4,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: 20,
                    color: AppTheme.errorColor,
                  ),
                  SizedBox(width: AppTheme.spacingSM + 4),
                  Expanded(
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const SignOutConfirmationDialog(),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
}
