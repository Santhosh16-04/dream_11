import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class Firebasemsg {
  final FirebaseMessaging msgService = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initFCM() async {
    // Request FCM push permission
    NotificationSettings settings = await msgService.requestPermission();
    print('Permission status: ${settings.authorizationStatus}');

    // Request POST_NOTIFICATIONS permission for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Get FCM token
    String? token = await msgService.getToken();
    print("FCM Token: $token");

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Request Android 13+ notifications permission via plugin API (in addition to permission_handler)
    final androidImpl =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    // Create notification channels
    await _createNotificationChannels();

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(handleNotification);
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel defaultChannel =
        AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'Default notification channel',
      importance: Importance.max,
    );

    const AndroidNotificationChannel reminderChannel =
        AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      description: 'Match reminder notifications',
      importance: Importance.max,
    );

    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(defaultChannel);
    await androidPlugin?.createNotificationChannel(reminderChannel);

    print('Notification channels created successfully');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'default_channel',
        'Default Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
      );
    }
  }

  Future<void> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      print('Scheduling notification: $title at $scheduledTime');

      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Ensure notifications permission (Android 13+)
      await androidPlugin?.requestNotificationsPermission();

      // Prefer exact when allowed; gracefully fall back to inexact if not granted
      bool canExact =
          await androidPlugin?.canScheduleExactNotifications() ?? true;
      if (!canExact) {
        await androidPlugin?.requestExactAlarmsPermission();
        canExact =
            await androidPlugin?.canScheduleExactNotifications() ?? false;
      }

      print('Can schedule exact alarms: $canExact');

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        channelDescription: 'Match reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      // Use a stable, unique id per scheduled time so multiple reminders can coexist
      final int notificationId =
          scheduledTime.millisecondsSinceEpoch.remainder(2147483647);

      // Convert to timezone-aware datetime
      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      print('Scheduling with ID: $notificationId, Time: $tzDateTime');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzDateTime,
        platformDetails,
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );

      print('Notification scheduled successfully!');
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> cancelAllScheduledNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('All scheduled notifications cancelled');
  }

  // Test method to show immediate notification
  Future<void> showTestNotification() async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        channelDescription: 'Match reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        999,
        'Test Notification',
        'This is a test notification to verify setup',
        platformDetails,
      );

      print('Test notification shown successfully!');
    } catch (e) {
      print('Error showing test notification: $e');
      rethrow;
    }
  }
}

// Must be top-level function
@pragma('vm:entry-point')
Future<void> handleNotification(RemoteMessage message) async {
  print('Background/terminated notification: ${message.notification?.title}');
}
