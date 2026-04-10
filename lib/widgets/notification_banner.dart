import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import '../models/notification_model.dart';

/// A fully responsive notification banner.
/// Handles long titles and bodies without overflow issues.
class NotificationBanner extends StatelessWidget {
  final NotificationModel notification;
  final String timeLabel;

  const NotificationBanner({
    super.key,
    required this.notification,
    this.timeLabel = 'now',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(14),
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2C34),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF25D366).withOpacity(0.5),
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 10),

                // Expanded column for title and body
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title + time row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 3,
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            flex: 1,
                            child: Text(
                              timeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF25D366),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Body text
                      Text(
                        notification.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the banner using overlay_support
void showFCMNotificationBanner(
  BuildContext context,
  NotificationModel notif, {
  String time = 'now',
}) {
  showOverlayNotification(
    (context) => NotificationBanner(notification: notif, timeLabel: time),
    duration: const Duration(seconds: 4),
  );
}
