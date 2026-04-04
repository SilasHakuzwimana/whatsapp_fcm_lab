class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.data = const {},
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        timestamp: map['timestamp'] != null
            ? DateTime.parse(map['timestamp'])
            : DateTime.now(),
        data: Map<String, dynamic>.from(map['data'] ?? {}),
        isRead: map['isRead'] ?? false,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
    'isRead': isRead,
  };
}
