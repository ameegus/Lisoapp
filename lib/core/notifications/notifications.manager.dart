import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';

class NotificationsManager {
  static final plugin = FlutterLocalNotificationsPlugin();
  static final console = Console(name: 'NotificationsManager');

  static void cancel(int id) => plugin.cancel(id);
  static void cancelAll() => plugin.cancelAll();

  static void init() async {
    const iosSettings = IOSInitializationSettings(
      onDidReceiveLocalNotification: onForegroundPayload,
    );

    const macosSettings = MacOSInitializationSettings();
    const androidSettings = AndroidInitializationSettings('ic_notification');

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macosSettings,
      ),
      onSelectNotification: onBackgroundPayload,
    );

    console.info("init");
  }

  static void notify({
    required final String title,
    required final String body,
  }) async {
    const iosDetails = IOSNotificationDetails();
    const macosDetails = MacOSNotificationDetails();
    const linuxDetails = LinuxNotificationDetails();

    const androidDetails = AndroidNotificationDetails(
      "general",
      "General",
      channelDescription: "General Notifications",
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
      linux: linuxDetails,
    );

    await plugin.show(
      PersistenceService.to.notificationId.val++,
      title,
      body,
      details,
      payload: '',
    );
  }

  static void onBackgroundPayload(String? payload) async {
    console.info('onBackgroundPayload payload: ' + payload!);
  }

  static void onForegroundPayload(
    int? id,
    String? title,
    String? body,
    String? payload,
  ) async {
    console.info('onForegroundPayload payload: ' + payload!);
  }
}
