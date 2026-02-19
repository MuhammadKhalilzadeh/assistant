import 'package:assistant/data/models/inbox_message_model.dart';
import 'package:assistant/providers/inbox_provider.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    final messagesAsync = ref.watch(inboxMessagesProvider);
    final statsAsync = ref.watch(inboxStatsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComposeDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(padding),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(inboxMessagesProvider);
                  ref.invalidate(inboxStatsProvider);
                },
                child: messagesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load messages',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.invalidate(inboxMessagesProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (messages) {
                    if (messages.isEmpty) {
                      return _buildEmptyState();
                    }

                    final stats = statsAsync.valueOrNull ?? InboxStats.empty();
                    final services = stats.services.isNotEmpty
                        ? stats.services
                        : messages.map((m) => m.service).toSet().toList();

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          children: [
                            _buildSummaryCard(
                              messages.length,
                              stats.unreadCount,
                              services.length,
                              padding,
                            ),
                            SizedBox(height: padding),
                            ...services.map((service) => _buildServiceSection(
                              service,
                              messages.where((m) => m.service == service).toList(),
                              padding,
                            )),
                            SizedBox(height: padding * 4), // Space for FAB
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            color: AppTheme.textTertiary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first message',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 8),
          const Text(
            'Inbox',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int total, int unread, int services, double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.mail, unread.toString(), 'Unread'),
          _buildStatItem(Icons.inbox, total.toString(), 'Total'),
          _buildStatItem(Icons.apps, services.toString(), 'Services'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSection(String service, List<InboxMessage> messages, double padding) {
    final IconData serviceIcon;
    switch (service.toLowerCase()) {
      case 'gmail':
        serviceIcon = Icons.email;
        break;
      case 'slack':
        serviceIcon = Icons.tag;
        break;
      case 'teams':
        serviceIcon = Icons.groups;
        break;
      default:
        serviceIcon = Icons.mail_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(serviceIcon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              service,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${messages.where((m) => !m.isRead).length} unread',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...messages.map((message) => _buildMessageItem(message, padding)),
        SizedBox(height: padding),
      ],
    );
  }

  Widget _buildMessageItem(InboxMessage message, double padding) {
    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(inboxMessagesProvider.notifier).deleteMessage(message.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: message.isRead ? AppTheme.cardColor : AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
          border: message.isRead ? null : Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              message.sender[0].toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  message.sender,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (message.isStarred)
                const Icon(Icons.star, color: Colors.amber, size: 16),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.subject,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                message.preview,
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(message.receivedAt),
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
              if (!message.isRead)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          onTap: () {
            if (!message.isRead) {
              ref.read(inboxMessagesProvider.notifier).markAsRead(message.id);
            }
          },
          onLongPress: () {
            ref.read(inboxMessagesProvider.notifier).toggleStar(message.id);
          },
        ),
      ),
    );
  }

  void _showComposeDialog() {
    final senderController = TextEditingController();
    final subjectController = TextEditingController();
    final previewController = TextEditingController();
    String selectedService = 'General';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Message',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedService,
                dropdownColor: AppTheme.cardColor,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Service',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['General', 'Gmail', 'Slack', 'Teams']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setModalState(() => selectedService = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: senderController,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'From',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: previewController,
                style: TextStyle(color: AppTheme.textPrimary),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Preview',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (senderController.text.isEmpty || subjectController.text.isEmpty) {
                      return;
                    }
                    final message = InboxMessage(
                      id: '',
                      service: selectedService,
                      sender: senderController.text,
                      subject: subjectController.text,
                      preview: previewController.text,
                      receivedAt: DateTime.now(),
                    );
                    ref.read(inboxMessagesProvider.notifier).addMessage(message);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Message', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
