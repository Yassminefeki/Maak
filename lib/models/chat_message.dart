// lib/models/chat_message.dart
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? actionRoute;
  final String? actionLabel;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionRoute,
    this.actionLabel,
  });
}
