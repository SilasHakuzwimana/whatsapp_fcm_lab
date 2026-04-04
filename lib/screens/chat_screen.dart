import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_model.dart';
import '../models/notification_model.dart';

class ChatScreen extends StatefulWidget {
  final ChatContact contact;
  final List<NotificationModel> notifications;

  const ChatScreen({
    super.key,
    required this.contact,
    required this.notifications,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    // Seed some initial messages
    _messages.addAll([
      ChatMessage(
        id: '1',
        sender: widget.contact.name,
        content:
            'Hey! This chat is integrated with Firebase Cloud Messaging 🔥',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isSentByMe: false,
      ),
      ChatMessage(
        id: '2',
        sender: 'Me',
        content:
            'Great! I can receive push notifications from Firebase Console.',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 55),
        ),
        isSentByMe: true,
      ),
      ChatMessage(
        id: '3',
        sender: widget.contact.name,
        content:
            'Go to Firebase Console → Cloud Messaging → Send a test message using your device token.',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 50),
        ),
        isSentByMe: false,
      ),
    ]);

    // Add any received FCM notifications as messages
    for (final n in widget.notifications) {
      _messages.add(
        ChatMessage(
          id: n.id,
          sender: '🔔 FCM Notification',
          content: '${n.title}\n${n.body}',
          timestamp: n.timestamp,
          isSentByMe: false,
          type: MessageType.notification,
        ),
      );
    }

    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: 'Me',
          content: text,
          timestamp: DateTime.now(),
          isSentByMe: true,
        ),
      );
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B141A)
          : const Color(0xFFE5DDD5),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1F2C34)
            : const Color(0xFF128C7E),
        leadingWidth: 30,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF25D366).withOpacity(0.3),
              child: Text(
                widget.contact.avatar,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.contact.isOnline ? 'online' : 'last seen recently',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                // Show date separator
                final showDate =
                    index == 0 ||
                    !_isSameDay(_messages[index - 1].timestamp, msg.timestamp);

                return Column(
                  children: [
                    if (showDate) _DateSeparator(date: msg.timestamp),
                    _MessageBubble(message: msg, isDark: isDark),
                  ],
                );
              },
            ),
          ),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: isDark ? const Color(0xFF1F2C34) : const Color(0xFFF0F2F5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A3942) : Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isNotification = message.type == MessageType.notification;

    if (isNotification) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 40),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF25D366).withOpacity(0.5)),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_active,
                  size: 14,
                  color: Color(0xFF25D366),
                ),
                SizedBox(width: 4),
                Text(
                  'FCM Notification Received',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF25D366),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(message.content, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Align(
      alignment: message.isSentByMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isSentByMe
              ? (isDark ? const Color(0xFF005C4B) : const Color(0xFFDCF8C6))
              : (isDark ? const Color(0xFF1F2C34) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: message.isSentByMe
                ? const Radius.circular(12)
                : const Radius.circular(0),
            bottomRight: message.isSentByMe
                ? const Radius.circular(0)
                : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.content),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                if (message.isSentByMe) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    size: 14,
                    color: Color(0xFF53BDEB),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final isToday =
        DateFormat('yyyyMMdd').format(date) ==
        DateFormat('yyyyMMdd').format(DateTime.now());
    final label = isToday ? 'TODAY' : DateFormat('MMMM d, yyyy').format(date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
