/// Inbox message model for backend-integrated inbox
class InboxMessage {
  final String id;
  final String service;
  final String sender;
  final String subject;
  final String preview;
  final bool isRead;
  final bool isStarred;
  final DateTime receivedAt;
  final DateTime createdAt;

  InboxMessage({
    required this.id,
    this.service = 'General',
    required this.sender,
    required this.subject,
    this.preview = '',
    this.isRead = false,
    this.isStarred = false,
    required this.receivedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  InboxMessage copyWith({
    String? id,
    String? service,
    String? sender,
    String? subject,
    String? preview,
    bool? isRead,
    bool? isStarred,
    DateTime? receivedAt,
    DateTime? createdAt,
  }) {
    return InboxMessage(
      id: id ?? this.id,
      service: service ?? this.service,
      sender: sender ?? this.sender,
      subject: subject ?? this.subject,
      preview: preview ?? this.preview,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      receivedAt: receivedAt ?? this.receivedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    return InboxMessage(
      id: json['id'] as String,
      service: json['service'] as String? ?? 'General',
      sender: json['sender'] as String,
      subject: json['subject'] as String,
      preview: json['preview'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      isStarred: json['isStarred'] as bool? ?? false,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'sender': sender,
      'subject': subject,
      'preview': preview,
      'isRead': isRead,
      'isStarred': isStarred,
      'receivedAt': receivedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'service': service,
      'sender': sender,
      'subject': subject,
      'preview': preview,
      'isRead': isRead,
      'isStarred': isStarred,
      'receivedAt': receivedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'service': service,
      'sender': sender,
      'subject': subject,
      'preview': preview,
      'isRead': isRead,
      'isStarred': isStarred,
    };
  }
}

/// Inbox statistics
class InboxStats {
  final int totalMessages;
  final int unreadCount;
  final int starredCount;
  final List<String> services;

  const InboxStats({
    required this.totalMessages,
    required this.unreadCount,
    required this.starredCount,
    required this.services,
  });

  factory InboxStats.fromJson(Map<String, dynamic> json) {
    return InboxStats(
      totalMessages: json['totalMessages'] as int? ?? 0,
      unreadCount: json['unreadCount'] as int? ?? 0,
      starredCount: json['starredCount'] as int? ?? 0,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMessages': totalMessages,
      'unreadCount': unreadCount,
      'starredCount': starredCount,
      'services': services,
    };
  }

  static InboxStats empty() {
    return const InboxStats(
      totalMessages: 0,
      unreadCount: 0,
      starredCount: 0,
      services: [],
    );
  }
}
