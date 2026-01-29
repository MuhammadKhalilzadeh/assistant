import 'package:assistant/data/mock/models/inbox_message_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final MockRepository _repository = MockRepository();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final messages = _repository.messages;
    final unreadCount = _repository.unreadMessagesCount;
    final services = _repository.messageServices;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Column(
            children: [
              _buildAppBar(padding),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      children: [
                        _buildSummaryCard(messages.length, unreadCount, services.length, padding),
                        SizedBox(height: padding),
                        ...services.map((service) => _buildServiceSection(
                          service,
                          messages.where((m) => m.service == service).toList(),
                          padding,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: AppTheme.spacingSM),
          const Expanded(
            child: Text(
              'Inbox',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int total, int unread, int services, double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem(Icons.mail, unread.toString(), 'Unread')),
          Expanded(child: _buildStatItem(Icons.inbox, total.toString(), 'Total')),
          Expanded(child: _buildStatItem(Icons.apps, services.toString(), 'Services')),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.spacingSM + AppTheme.spacingXS),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: AppTheme.spacingSM),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSection(String service, List<InboxMessageModel> messages, double padding) {
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
            Icon(serviceIcon, color: Colors.white, size: 20),
            SizedBox(width: AppTheme.spacingSM),
            Expanded(
              child: Text(
                service,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppTheme.spacingSM),
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSM, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${messages.where((m) => !m.isRead).length} unread',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingSM + AppTheme.spacingXS),
        ...messages.map((message) => _buildMessageItem(message, padding)),
        SizedBox(height: padding),
      ],
    );
  }

  Widget _buildMessageItem(InboxMessageModel message, double padding) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacingSM),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: message.isRead ? 0.1 : 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: message.isRead ? 0.1 : 0.3),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: padding, vertical: AppTheme.spacingXS),
        leading: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: Text(
            message.sender[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
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
                  color: Colors.white,
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
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppTheme.spacingXS / 2),
            Text(
              message.preview,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
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
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
            if (!message.isRead)
              Container(
                margin: EdgeInsets.only(top: AppTheme.spacingXS),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          _repository.markMessageAsRead(message.id);
          setState(() {});
        },
        onLongPress: () {
          _repository.toggleMessageStar(message.id);
          setState(() {});
        },
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
