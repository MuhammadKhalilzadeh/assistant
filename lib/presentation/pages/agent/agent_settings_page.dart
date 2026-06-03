import 'package:assistant/data/services/agent_api_service.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class AgentSettingsPage extends StatefulWidget {
  const AgentSettingsPage({super.key});

  @override
  State<AgentSettingsPage> createState() => _AgentSettingsPageState();
}

class _AgentSettingsPageState extends State<AgentSettingsPage> {
  final _api = AgentApiService();
  AgentSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _api.getSettings();
      if (mounted) setState(() { _settings = settings; _isLoading = false; });
    } catch (_) {
      if (mounted) {
        setState(() {
          _settings = const AgentSettings(
            autonomyLevel: 'suggest_only',
            goalChanges: 'ask_first',
            reminders: 'auto_with_notify',
            dataLogging: 'suggest_only',
          );
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_settings == null) return;
    setState(() => _isSaving = true);
    try {
      await _api.updateSettings(_settings!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Settings saved'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Agent Settings'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          if (!_isLoading && !_isSaving)
            TextButton(
              onPressed: _save,
              child: Text('Save',
                  style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600)),
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Explanation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Control how autonomous Jarvis can be. Higher autonomy '
                    'means Jarvis can take actions on your behalf without '
                    'asking first. All actions are logged and undoable.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.5),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSettingDropdown(
                  'Global Autonomy Level',
                  'Default behavior for all agent actions',
                  _settings!.autonomyLevel,
                  (val) => setState(() => _settings = AgentSettings(
                        autonomyLevel: val,
                        goalChanges: _settings!.goalChanges,
                        reminders: _settings!.reminders,
                        dataLogging: _settings!.dataLogging,
                      )),
                ),
                const SizedBox(height: 16),

                _buildSettingDropdown(
                  'Goal Changes',
                  'How Jarvis handles goal adjustment suggestions',
                  _settings!.goalChanges,
                  (val) => setState(() => _settings = AgentSettings(
                        autonomyLevel: _settings!.autonomyLevel,
                        goalChanges: val,
                        reminders: _settings!.reminders,
                        dataLogging: _settings!.dataLogging,
                      )),
                ),
                const SizedBox(height: 16),

                _buildSettingDropdown(
                  'Reminders',
                  'How freely Jarvis can send reminders',
                  _settings!.reminders,
                  (val) => setState(() => _settings = AgentSettings(
                        autonomyLevel: _settings!.autonomyLevel,
                        goalChanges: _settings!.goalChanges,
                        reminders: val,
                        dataLogging: _settings!.dataLogging,
                      )),
                ),
                const SizedBox(height: 16),

                _buildSettingDropdown(
                  'Data Logging',
                  'Whether Jarvis can log data on your behalf',
                  _settings!.dataLogging,
                  (val) => setState(() => _settings = AgentSettings(
                        autonomyLevel: _settings!.autonomyLevel,
                        goalChanges: _settings!.goalChanges,
                        reminders: _settings!.reminders,
                        dataLogging: val,
                      )),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingDropdown(
    String title,
    String subtitle,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: const [
              DropdownMenuItem(
                  value: 'suggest_only', child: Text('Suggest Only')),
              DropdownMenuItem(
                  value: 'ask_first', child: Text('Ask First')),
              DropdownMenuItem(
                  value: 'auto_with_notify',
                  child: Text('Auto + Notify')),
              DropdownMenuItem(
                  value: 'full_auto', child: Text('Full Auto')),
            ],
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
            style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
            dropdownColor: AppTheme.cardColor,
          ),
        ],
      ),
    );
  }
}
