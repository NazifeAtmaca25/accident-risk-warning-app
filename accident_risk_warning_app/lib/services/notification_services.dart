import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices{
  static final NotificationServices _instance=NotificationServices();
  factory NotificationServices()=>_instance;
  NotificationServices._internal();
  
  final FlutterLocalNotificationsPlugin _notifications=FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async{
    const AndroidInitializationSettings initializationSettingsAndroid=AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings=InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(initializationSettings);
  }

  Future<void> showDangerZoneNotification() async{
    const AndroidNotificationDetails androidPlatformChannelSpecifics= AndroidNotificationDetails('danger_zone_channel', "Tehlike Bölge Uyarısı",channelDescription: 'Tehlikeli bölge uyarıları için bildirim kanalı',importance: Importance.max,
    priority: Priority.high,showWhen: false);

    const NotificationDetails platformChanneSpecifics=NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.show(0, 'UYARI: Tehlikeli Bölge', 'Tehlikeli bir bölgeye girdin,z. Dikkatli olun!', platformChanneSpecifics,payload: 'danger_zone_entered');
  }
}