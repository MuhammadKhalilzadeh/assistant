class InboxMessageModel {
  final String id;
  final String service; // e.g., 'Gmail', 'Slack', 'Teams'
  final String sender;
  final String subject;
  final String preview;
  final DateTime receivedAt;
  final bool isRead;
  final bool isStarred;

  InboxMessageModel({
    required this.id,
    required this.service,
    required this.sender,
    required this.subject,
    required this.preview,
    required this.receivedAt,
    this.isRead = false,
    this.isStarred = false,
  });

  InboxMessageModel copyWith({
    String? id,
    String? service,
    String? sender,
    String? subject,
    String? preview,
    DateTime? receivedAt,
    bool? isRead,
    bool? isStarred,
  }) {
    return InboxMessageModel(
      id: id ?? this.id,
      service: service ?? this.service,
      sender: sender ?? this.sender,
      subject: subject ?? this.subject,
      preview: preview ?? this.preview,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
    );
  }
}
