import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationHelper {
  LocalNotificationHelper._();
  static final LocalNotificationHelper localNotificationHelper =
      LocalNotificationHelper._();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> sendSimpleNotication({required int id}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('Demo Id', 'Bhumit  Channel',
            importance: Importance.max, priority: Priority.max);
    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        1, 'UpDate Your Data', 'ID : $id', notificationDetails,
        payload: "This is the simple notification paylod");
  }

  Future<void> sendScheduleNotifincation({required int id}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('Demo Id', 'Bhumit  Channel',
            importance: Importance.max, priority: Priority.max);
    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "New Recode Is Successfull.............",
        "ID : $id",
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  sendBigPictureNotifications() async {
    BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
            DrawableResourceAndroidBitmap("mipmap/ic_launcher"),
            largeIcon: DrawableResourceAndroidBitmap("mipmap/ic_launcher"));

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('Demo Id', 'Bhumit  Channel',
            importance: Importance.max,
            priority: Priority.max,
            styleInformation: bigPictureStyleInformation);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails, iOS: null);

    await flutterLocalNotificationsPlugin.show(
        1, 'UpDate Your Data', 'ID : 1', notificationDetails,
        payload: "This is the big picture notification paylod");
  }

  sendMediaNotification() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('Demo Id', 'Bhumit  Channel',
            importance: Importance.max,
            priority: Priority.max,
            styleInformation: MediaStyleInformation());

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails, iOS: null);

    await flutterLocalNotificationsPlugin.show(
        1, 'UpDate Your Data', 'ID : 1', notificationDetails,
        payload: "This is the big picture notification paylod");
  }
}
