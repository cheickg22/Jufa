enum MessageType {
  text,
  image,
  file,
  typing,
}

enum MessageSender {
  user,
  assistant,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final MessageSender sender;
  final DateTime timestamp;
  final List<QuickReply>? quickReplies;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.sender,
    DateTime? timestamp,
    this.quickReplies,
    this.isTyping = false,
  }) : timestamp = timestamp ?? DateTime.now();

  // Alias pour compatibilité
  String get text => content;

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageSender? sender,
    DateTime? timestamp,
    List<QuickReply>? quickReplies,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      quickReplies: quickReplies ?? this.quickReplies,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class QuickReply {
  final String id;
  final String text;
  final String action;

  QuickReply({
    required this.id,
    required this.text,
    required this.action,
  });
}
