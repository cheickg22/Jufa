class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final MessageSender sender;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final List<QuickReply>? quickReplies;
  final bool isTyping;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.sender,
    required this.timestamp,
    this.metadata,
    this.quickReplies,
    this.isTyping = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => MessageType.text,
      ),
      sender: MessageSender.values.firstWhere(
        (sender) => sender.value == json['sender'],
        orElse: () => MessageSender.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
      quickReplies: json['quick_replies'] != null
          ? List<QuickReply>.from(
              json['quick_replies'].map((x) => QuickReply.fromJson(x)),
            )
          : null,
      isTyping: json['is_typing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.value,
      'sender': sender.value,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'quick_replies': quickReplies?.map((x) => x.toJson()).toList(),
      'is_typing': isTyping,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageSender? sender,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    List<QuickReply>? quickReplies,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      quickReplies: quickReplies ?? this.quickReplies,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class QuickReply {
  final String id;
  final String text;
  final String action;
  final Map<String, dynamic>? payload;

  const QuickReply({
    required this.id,
    required this.text,
    required this.action,
    this.payload,
  });

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      action: json['action'] ?? '',
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'action': action,
      'payload': payload,
    };
  }
}

enum MessageType {
  text('text', 'Texte'),
  image('image', 'Image'),
  file('file', 'Fichier'),
  quickReply('quick_reply', 'Réponse rapide'),
  card('card', 'Carte'),
  chart('chart', 'Graphique'),
  transaction('transaction', 'Transaction'),
  recommendation('recommendation', 'Recommandation');

  const MessageType(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum MessageSender {
  user('user', 'Utilisateur'),
  assistant('assistant', 'Assistant'),
  system('system', 'Système');

  const MessageSender(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Modèle pour l'assistant IA
class AIAssistant {
  final String id;
  final String name;
  final String avatar;
  final String description;
  final List<String> capabilities;
  final AssistantStatus status;
  final DateTime? lastActive;

  const AIAssistant({
    required this.id,
    required this.name,
    required this.avatar,
    required this.description,
    required this.capabilities,
    required this.status,
    this.lastActive,
  });

  factory AIAssistant.fromJson(Map<String, dynamic> json) {
    return AIAssistant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      description: json['description'] ?? '',
      capabilities: List<String>.from(json['capabilities'] ?? []),
      status: AssistantStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => AssistantStatus.offline,
      ),
      lastActive: DateTime.parse(json['last_active'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Assistant par défaut
  static AIAssistant get jufa => const AIAssistant(
    id: 'jufa_ai',
    name: 'Jufa AI',
    avatar: '🤖',
    description: 'Votre assistant financier intelligent',
    capabilities: [
      'Analyse des dépenses',
      'Conseils d\'épargne',
      'Prédictions financières',
      'Détection de fraude',
      'Support 24/7',
    ],
    status: AssistantStatus.online,
    lastActive: null,
  );
}

enum AssistantStatus {
  online('online', 'En ligne', '🟢'),
  busy('busy', 'Occupé', '🟡'),
  offline('offline', 'Hors ligne', '🔴');

  const AssistantStatus(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

// Contexte de conversation
class ConversationContext {
  final String userId;
  final Map<String, dynamic> userProfile;
  final List<String> recentTransactions;
  final Map<String, double> spendingCategories;
  final double currentBalance;
  final List<String> activeGoals;

  const ConversationContext({
    required this.userId,
    required this.userProfile,
    required this.recentTransactions,
    required this.spendingCategories,
    required this.currentBalance,
    required this.activeGoals,
  });

  factory ConversationContext.fromJson(Map<String, dynamic> json) {
    return ConversationContext(
      userId: json['user_id'] ?? '',
      userProfile: json['user_profile'] ?? {},
      recentTransactions: List<String>.from(json['recent_transactions'] ?? []),
      spendingCategories: Map<String, double>.from(json['spending_categories'] ?? {}),
      currentBalance: (json['current_balance'] ?? 0.0).toDouble(),
      activeGoals: List<String>.from(json['active_goals'] ?? []),
    );
  }
}
