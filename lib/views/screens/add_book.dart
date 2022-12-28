import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../helper/fcm_notification_helper.dart';
import '../../helper/firestore_helper.dart';
import '../../helper/local_notification_helper.dart';

class add_book extends StatefulWidget {
  const add_book({Key? key}) : super(key: key);

  @override
  State<add_book> createState() => _add_bookState();
}

class _add_bookState extends State<add_book> with WidgetsBindingObserver {
  String? image;
  File? imagefile2;
  String pathImage = "";
  String error1 = "";
  final ImagePicker picker = ImagePicker();

  TextEditingController namecontroller = TextEditingController();
  TextEditingController authorcontroller = TextEditingController();

  final GlobalKey<FormState> controller = GlobalKey<FormState>();

  clear() {
    image = "";
    pathImage = "";
    error1 = "";
    namecontroller.clear();
    authorcontroller.clear();
  }

  Future<void> getToken() async {
    String? token =
        await Firebase_MessageHelper.firebase_message.getFCMDeviceToken();
    print("============================================");
    print(token);
    print("============================================");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    clear();

    getToken();
    //FCM Notifincation
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Notification arrived in foreground");

      print("Notification Title : ${message.notification!.title}");
      print("Notification Title : ${message.notification!.body}");

      print("Data : ${message.data}");

      await LocalNotificationHelper.localNotificationHelper
          .sendSimpleNotication(id: 1);
    });
    //End of FCM Notifincation

    //local notification start
    WidgetsBinding.instance.addObserver(this);

    var adroidIntialzeSettings =
        AndroidInitializationSettings("mipmap/ic_launcher");
    var iosIntialzeSettings = DarwinInitializationSettings();
    var initalizeSettins = InitializationSettings(
        android: adroidIntialzeSettings, iOS: iosIntialzeSettings);

    tz.initializeTimeZones();

    LocalNotificationHelper.flutterLocalNotificationsPlugin
        .initialize(initalizeSettins,
            onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("================");
      print(response);
      print("================");
    });
    //local notifincation end
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        {
          print("App Is Inncative");
          break;
        }
      case AppLifecycleState.paused:
        {
          print("App Is Paused");
          break;
        }
      case AppLifecycleState.resumed:
        {
          print("App is resumed");
          break;
        }
      case AppLifecycleState.detached:
        {
          print("App is Terminates");
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    Future<Uint8List> testComporessList(Uint8List list) async {
      var result = await FlutterImageCompress.compressWithList(
        list, minHeight: 450,
        minWidth: 450,
        quality: 99,
        // rotate: 135,
      );
      print(list.length);
      print(result.length);
      return result;
    }

    return Scaffold(
      appBar: AppBar(title: Text("Add Book"), centerTitle: true),
      body: StreamBuilder(
        stream: FireStoreHelper.fireStoreHelper.fecthchCount(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error : ${snapshot.error}"));
          } else if (snapshot.hasData) {
            QuerySnapshot? querySnapshort = snapshot.data;
            List<QueryDocumentSnapshot> allDocs = querySnapshort!.docs;
            int count = allDocs[0]['count'];
            count = ++count;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: controller,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("ID : $count"),
                      SizedBox(height: 30),
                      Stack(
                        alignment: Alignment(1.3, 1.1),
                        children: [
                          Container(
                              height: _height * 0.301,
                              width: _width * 0.5,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: ([...Colors.primaries]..shuffle())
                                      .first
                                      .shade200,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.black, width: 5)),
                              child: (imagefile2 != null)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        imagefile2!,
                                        height: _height * 0.9,
                                        width: _width * 0.48,
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : Text(
                                      "Enter You Book Image and 300*400",
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    )),
                          FloatingActionButton(
                            onPressed: () async {
                              print(_height * 0.301);
                              print(_width * 0.5);
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: SelectableText(
                                            "You Choise Is Image"),
                                        actions: [
                                          IconButton(
                                              onPressed: () async {
                                                try {
                                                  var pickedFile =
                                                      await picker.pickImage(
                                                          source: ImageSource
                                                              .camera);

                                                  //you can use ImageCourse.camera for Camera capture
                                                  if (pickedFile != null) {
                                                    pathImage = pickedFile.path;

                                                    setState(() {
                                                      error1 = "";
                                                      imagefile2 =
                                                          File(pathImage);
                                                    }); //convert Path to File
                                                    Uint8List imagebytes =
                                                        await imagefile2!
                                                            .readAsBytes();

                                                    imagebytes =
                                                        await testComporessList(
                                                            imagebytes);

                                                    setState(() {
                                                      image = base64
                                                          .encode(imagebytes);
                                                    });
                                                  } else {
                                                    print(
                                                        "No image is selected.");
                                                  }
                                                } catch (e) {
                                                  print(
                                                      "error while picking file.");
                                                }
                                                setState(() {
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                              icon: Icon(Icons.camera)),
                                          SizedBox(width: 40),
                                          IconButton(
                                              onPressed: () async {
                                                try {
                                                  var pickedFile =
                                                      await picker.pickImage(
                                                          source: ImageSource
                                                              .gallery);

                                                  if (pickedFile != null) {
                                                    pathImage = pickedFile.path;
                                                    setState(() {
                                                      error1 = "";
                                                      imagefile2 =
                                                          File(pathImage);
                                                    });
                                                    Uint8List imagebytes =
                                                        await imagefile2!
                                                            .readAsBytes();
                                                    imagebytes =
                                                        await testComporessList(
                                                            imagebytes);
                                                    setState(() {
                                                      image = base64
                                                          .encode(imagebytes);
                                                    });
                                                  } else {
                                                    print(
                                                        "No image is selected.");
                                                  }
                                                } catch (e) {
                                                  print(
                                                      "error while picking file.");
                                                }
                                                setState(() {
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                              icon: Icon(Icons.album))
                                        ],
                                      ));
                            },
                            child: Icon(Icons.add),
                            mini: true,
                          )
                        ],
                      ),
                      Text(
                        error1,
                        style: TextStyle(fontSize: 20, color: Colors.red),
                      ),
                      SizedBox(height: 50),
                      Text("Book Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(height: 5),
                      TextFormField(
                          controller: namecontroller,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Enter Book Name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Enter Book Name")),
                      SizedBox(height: 50),
                      Text("Author Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(height: 5),
                      TextFormField(
                          controller: authorcontroller,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Enter Author Name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Enter Author Name")),
                      SizedBox(height: 50),
                      ElevatedButton(
                          onPressed: () async {
                            if (controller.currentState!.validate()) {
                              if (imagefile2 != null) {
                                Map<String, dynamic> data = {
                                  "id": count,
                                  "image": image,
                                  "book_name": namecontroller.text,
                                  "author_name": authorcontroller.text,
                                  "favorite": false
                                };
                                Map<String, dynamic> data2 = {
                                  "count": count,
                                };

                                FireStoreHelper.fireStoreHelper.insertData(
                                    name: "books_detail", data: data);
                                FireStoreHelper.fireStoreHelper.UpdateCount(
                                    data: data2, name: "book_count");

                                await LocalNotificationHelper
                                    .localNotificationHelper
                                    .sendScheduleNotifincation(id: count);

                                Navigator.of(context).pop();
                              } else {
                                setState(() {
                                  error1 = "Enter You Book Image";
                                });
                              }
                            }
                          },
                          child: Text("Save"))
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
