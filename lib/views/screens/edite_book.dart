import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:authors_app/helper/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../helper/local_notification_helper.dart';

class edite_book extends StatefulWidget {
  const edite_book({Key? key}) : super(key: key);

  @override
  State<edite_book> createState() => _edite_bookState();
}

class _edite_bookState extends State<edite_book> {
  String? image;
  File? imagefile2;
  String pathImage = "";
  String error1 = "";
  final ImagePicker picker = ImagePicker();

  TextEditingController UpdateName = TextEditingController();
  TextEditingController UpdateAuthor = TextEditingController();
  final GlobalKey<FormState> controller = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("image$image");

    // WidgetsBinding.instance.addObserver(this);

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
  }

  @override
  Widget build(BuildContext context) {
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

    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    Map<String, dynamic> res =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Uint8List imageU = base64.decode(res['image']);

    (UpdateName.text == "") ? UpdateName.text = res['book_name'] : null;
    (UpdateAuthor.text == "") ? UpdateAuthor.text = res['author_name'] : null;

    return Scaffold(
      appBar: AppBar(title: Text("Edite Detail"), centerTitle: true),
      body: Center(
        child: Form(
          key: controller,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Stack(
                    alignment: Alignment(1.3, 1.1),
                    children: [
                      Container(
                          height: _height * 0.32,
                          width: _width * 0.5,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: Colors.black, width: 5)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: (image == null)
                                ? Image.memory(imageU,
                                    height: _height * 0.4,
                                    width: _width * 0.5,
                                    fit: BoxFit.cover)
                                : Image.file(imagefile2!,
                                    height: _height * 0.3,
                                    width: _width * 0.5,
                                    fit: BoxFit.fill),
                          )),
                      FloatingActionButton(
                        onPressed: () async {
                          print(_height * 0.301);
                          print(_width * 0.5);
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title:
                                        SelectableText("You Choise Is Image"),
                                    actions: [
                                      IconButton(
                                          onPressed: () async {
                                            try {
                                              var pickedFile =
                                                  await picker.pickImage(
                                                      source:
                                                          ImageSource.camera);

                                              //you can use ImageCourse.camera for Camera capture
                                              if (pickedFile != null) {
                                                pathImage = pickedFile.path;

                                                setState(() {
                                                  error1 = "";
                                                  imagefile2 = File(pathImage);
                                                }); //
                                                // convert Path to File
                                                Uint8List imagebytes =
                                                    await imagefile2!
                                                        .readAsBytes();

                                                imagebytes =
                                                    await testComporessList(
                                                        imagebytes);

                                                setState(() {
                                                  image =
                                                      base64.encode(imagebytes);
                                                });
                                              } else {
                                                print("No image is selected.");
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
                                                      source:
                                                          ImageSource.gallery);

                                              if (pickedFile != null) {
                                                pathImage = pickedFile.path;
                                                setState(() {
                                                  error1 = "";
                                                  imagefile2 = File(pathImage);
                                                });
                                                Uint8List imagebytes =
                                                    await imagefile2!
                                                        .readAsBytes();
                                                imagebytes =
                                                    await testComporessList(
                                                        imagebytes);
                                                setState(() {
                                                  image =
                                                      base64.encode(imagebytes);
                                                });
                                              } else {
                                                print("No image is selected.");
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
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Book Name",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: UpdateName,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Valid Book Name";
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter Book Name"),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Author Name",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: UpdateAuthor,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Valid Author Name";
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter Author Name"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () async {
                        if (controller.currentState!.validate()) {
                          Map<String, dynamic> data = {
                            "author_name": UpdateAuthor.text,
                            "book_name": UpdateName.text,
                            "image": (image != null) ? image : res['image']
                          };
                          FireStoreHelper.fireStoreHelper.UpdateRecode(
                              id: res['id'].toString(),
                              data: data,
                              name: "books_detail");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("You Data Is UpDate Successfuly......."),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating));
                          await LocalNotificationHelper.localNotificationHelper
                              .sendSimpleNotication(id: res['id']);
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      },
                      child: Text("Save"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
