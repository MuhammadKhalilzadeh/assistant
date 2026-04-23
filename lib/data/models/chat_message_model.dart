enum MessageRole {
  user,
  assistant,
  system;

  String get label {
    switch (this) {
      case MessageRole.user:
        return 'user';
      case MessageRole.assistant:
        return 'assistant';
      case MessageRole.system:
        return 'system';
    }
  }
}

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      content: json['content'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      isError: json['isError'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }

  /// Create a user message
  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content,
    );
  }

  /// Create an assistant message
  factory ChatMessage.assistant(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: content,
    );
  }

  /// Create an error message (displayed as assistant message)
  factory ChatMessage.error(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: content,
      isError: true,
    );
  }

  /// Create a system message
  factory ChatMessage.system(String content) {
    return ChatMessage(
      id: 'system-${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.system,
      content: content,
    );
  }
}
