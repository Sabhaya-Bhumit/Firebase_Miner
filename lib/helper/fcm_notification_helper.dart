import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class Firebase_MessageHelper {
  Firebase_MessageHelper._();
  static final Firebase_MessageHelper firebase_message =
      Firebase_MessageHelper._();
  static final FirebaseMessaging firebaseMessage = FirebaseMessaging.instance;

  Future<String> getFCMDeviceToken() async {
    String? token = await firebaseMessage.getToken();
    return token!;
  }

  sendFCMPushNotification() async {
    Map<String, String> myHeader = {
      "Content-Type": "application/json",
      "Authorization":
          "key=AAAAjFpcPR4:APA91bETL_-JKWUjzcDdyCFHPZ_iAA6EeEN47eT_v1Jq8I7S11R2xiMIlsyiiqk6YnbByLSf66iCqwkxYOqFZyLA6U22r_xa1BZFTeCOufWtMQOyf065STgm2DtoLMK-yOXH_ZRJmVNy",
    };
    Map myBody = {
      "to":
          "cojr1RvcQGqUC6arPHknNz:APA91bHOJfyFrq8CEVOKUSJi1qlT7jbubredtGVHPm2DSR1n22aqgRM-Z7DNV81hefMZbqvhkgS2gz1N61yrJ90UBh_1IaP6mYMoaWDt92qCgpxos-y9FftzHu9VEb7CPpyyV8kc3tsK",
      "notification": {
        "content_available": true,
        "priority": "high",
        "title": "hello",
        "body": "My Body"
      },
      "data": {
        "priority": "high",
        "content_available": true,
        "school": "abc",
        "age": "20"
      }
    };

    http.Response res = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: myHeader,
        body: jsonEncode(myBody));
    if (res.statusCode == 200) {
      Map decodeData = jsonDecode(res.body);
      if (decodeData['success'] == 1) {
        print("===================");
        print("Notification send arrived successfuly.........");
        print("===================");
      }
    }
  }
}
