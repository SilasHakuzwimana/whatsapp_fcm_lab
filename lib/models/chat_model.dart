enum MessageType { text, notification, system }

class ChatMessage {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isSentByMe;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.isSentByMe = false,
  });
}

class ChatContact {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatContact({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}
