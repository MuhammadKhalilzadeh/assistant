import 'package:hive/hive.dart';

part 'inbox_message_model.g.dart';

@HiveType(typeId: 19)
class InboxMessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String service; // e.g., 'Gmail', 'Slack', 'Teams'

  @HiveField(2)
  final String sender;

  @HiveField(3)
  final String subject;

  @HiveField(4)
  final String preview;

  @HiveField(5)
  final DateTime receivedAt;

  @HiveField(6)
  final bool isRead;

  @HiveField(7)
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
