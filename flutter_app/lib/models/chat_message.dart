class ChatMessage {
  final int id;
  final String senderUsername;
  final int senderId;
  final String text;
  final DateTime sentAt;

  ChatMessage({
    required this.id,
    required this.senderUsername,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    final s = Map<String, dynamic>.from(j['sender'] as Map);
    return ChatMessage(
      id: j['id'] as int,
      senderUsername: s['username'] as String,
      senderId: s['id'] as int,
      text: j['text'] as String,
      sentAt: DateTime.parse(j['sent_at'] as String),
    );
  }
}
