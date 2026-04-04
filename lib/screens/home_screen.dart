import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';

import '../models/chat_model.dart';
import '../models/notification_model.dart';
import '../services/fcm_service.dart';
import '../widgets/notification_banner.dart';
import '../widgets/notification_popup.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';
import 'token_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FCMService _fcmService = FCMService();
  final List<NotificationModel> _notifications = [];

  final List<ChatContact> _contacts = [
    ChatContact(
      id: '1',
      name: 'Firebase Console',
      avatar: '🔥',
      lastMessage: 'Send a test notification →',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      unreadCount: 0,
      isOnline: true,
    ),
    ChatContact(
      id: '2',
      name: 'FCM Bot',
      avatar: '🤖',
      lastMessage: 'Waiting for push notifications...',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: true,
    ),
    ChatContact(
      id: '3',
      name: 'Dev Team',
      avatar: '👨‍💻',
      lastMessage: 'FCM integration complete! 🎉',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 2,
      isOnline: false,
    ),
    ChatContact(
      id: '4',
      name: 'Alice',
      avatar: '👩',
      lastMessage: 'Did you receive the notification?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: true,
    ),
    ChatContact(
      id: '5',
      name: 'Bob',
      avatar: '👨',
      lastMessage: 'Yes! The token is ready',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _initFCM();
  }

  Future<void> _initFCM() async {
    await _fcmService.initialize();

    // Handle foreground notifications — show overlay banner
    _fcmService.onNotificationReceived = (notification) {
      if (!mounted) return;
      setState(() {
        _notifications.insert(0, notification);
      });
      _showInAppBanner(notification);
      _showPopupDialog(notification);
    };

    // Handle notification tap
    _fcmService.onNotificationTapped = (notification) {
      if (!mounted) return;
      setState(() {
        _notifications.insert(0, notification);
        _tabController.animateTo(2); // Switch to notifications tab
      });
    };
  }

  void _showInAppBanner(NotificationModel notification) {
    showOverlayNotification(
      (context) => NotificationBanner(notification: notification),
      duration: const Duration(seconds: 4),
      position: NotificationPosition.top,
    );
  }

  void _showPopupDialog(NotificationModel notification) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => NotificationPopup(notification: notification),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGreen = const Color(0xFF25D366);
    final darkGreen = const Color(0xFF128C7E);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111B21)
          : const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1F2C34) : darkGreen,
        title: const Text(
          'WhatsApp FCM',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_rounded, color: Colors.white),
            tooltip: 'View Device Token',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TokenScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMenu(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            const Tab(text: 'CHATS'),
            const Tab(text: 'STATUS'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('ALERTS'),
                  if (_notifications.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_notifications.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsTab(isDark),
          _buildStatusTab(isDark),
          NotificationsScreen(notifications: _notifications),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Use Firebase Console to send notifications'),
              backgroundColor: Color(0xFF128C7E),
            ),
          );
        },
        child: const Icon(Icons.message_rounded),
      ),
    );
  }

  Widget _buildChatsTab(bool isDark) {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return _ChatTile(
          contact: contact,
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChatScreen(contact: contact, notifications: _notifications),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusTab(bool isDark) {
    return ListView(
      children: [
        Container(
          color: isDark ? const Color(0xFF1F2C34) : Colors.white,
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF25D366).withOpacity(0.2),
                  child: const Text('👤', style: TextStyle(fontSize: 24)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
            title: const Text(
              'My Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Tap to add status update'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'RECENT UPDATES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        _buildStatusItem('🔥', 'Firebase Console', '2 minutes ago'),
        _buildStatusItem('🤖', 'FCM Bot', '1 hour ago'),
        _buildStatusItem('👩', 'Alice', 'Today, 09:45 AM'),
      ],
    );
  }

  Widget _buildStatusItem(String avatar, String name, String time) {
    return ListTile(
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: const Color(0xFF25D366),
        child: Text(avatar, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(time),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.vpn_key_rounded,
              color: Color(0xFF25D366),
            ),
            title: const Text('View FCM Token'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TokenScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFF25D366),
            ),
            title: const Text('Notification History'),
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(2);
            },
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatContact contact;
  final bool isDark;
  final VoidCallback onTap;

  const _ChatTile({
    required this.contact,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          tileColor: isDark ? const Color(0xFF111B21) : Colors.white,
          onTap: onTap,
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF25D366).withOpacity(0.15),
                child: Text(
                  contact.avatar,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              if (contact.isOnline)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF111B21) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                contact.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _formatTime(contact.lastMessageTime),
                style: TextStyle(
                  fontSize: 12,
                  color: contact.unreadCount > 0
                      ? const Color(0xFF25D366)
                      : Colors.grey,
                ),
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  contact.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              if (contact.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${contact.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(
          height: 1,
          indent: 80,
          color: isDark ? Colors.white12 : Colors.grey[200],
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}
