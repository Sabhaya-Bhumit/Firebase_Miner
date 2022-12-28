import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../helper/firestore_helper.dart';

class detail_page extends StatefulWidget {
  const detail_page({Key? key}) : super(key: key);

  @override
  State<detail_page> createState() => _detail_pageState();
}

class _detail_pageState extends State<detail_page> {
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    ScreenshotController screenshotController = ScreenshotController();
    var image;
    Map<String, dynamic> res =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Uint8List imageU = base64.decode(res['image']);
    image = imageU;
    return Scaffold(
      appBar: AppBar(title: Text("Detail Page"), centerTitle: true),
      backgroundColor: ([...Colors.primaries]..shuffle()).first.shade200,
      body: Column(
        children: [
          Screenshot(
              child: Container(
                height: _height * 0.8,
                width: _width,
                color: ([...Colors.primaries]..shuffle()).first.shade200,
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Container(
                        height: _height * 0.37,
                        width: _width * 0.55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black,
                              width: 5,
                            )),
                        child: (image != null)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  image,
                                  height: _height * 0.5,
                                  width: _width * 0.6,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                "Enter ",
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              )),
                    SizedBox(height: 50),
                    Text("Book Name",
                        style: TextStyle(
                            fontSize: _height * 0.035,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("${res['book_name']}",
                        style: TextStyle(fontSize: _height * 0.032)),
                    SizedBox(height: 20),
                    Divider(
                      indent: 20,
                      endIndent: 20,
                      thickness: 5,
                      color: Colors.black,
                    ),
                    SizedBox(height: 20),
                    Text("Author Name",
                        style: TextStyle(
                            fontSize: _height * 0.034,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text("${res['author_name']}",
                        style: TextStyle(fontSize: _height * 0.032),
                        overflow: TextOverflow.visible),
                    SizedBox(height: 60),
                  ],
                ),
              ),
              controller: screenshotController),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed('edite_book', arguments: res);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blueAccent,
                  )),
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Do you want to delete it?"),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  FireStoreHelper.fireStoreHelper.DeleteRecode(
                                      id: res['id'].toString(),
                                      data: res,
                                      name: "books_detail");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "You Note Recode Delete Successfuly..........."),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating));
                                  Navigator.of(context).pop();
                                },
                                child: Text("Yes")),
                            SizedBox(width: 5),
                            OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("No")),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  )),
              IconButton(
                  onPressed: () {
                    setState(() {
                      bool favorite = res['favorite'];
                      favorite = !favorite;
                      Map<String, dynamic> data = {
                        "favorite": favorite,
                      };
                      FireStoreHelper.fireStoreHelper.UpdateRecode(
                          id: res['id'].toString(),
                          data: data,
                          name: "books_detail");
                      print(res['favorite']);
                    });
                  },
                  icon: Icon(
                    (res['favorite'])
                        ? Icons.favorite_rounded
                        : Icons.favorite_border,
                    color: Colors.redAccent,
                  )),
              IconButton(
                  onPressed: () async {
                    final image = await screenshotController.capture();
                    if (image == null) return;

                    await saveImage(image);
                    saveAndShare(image);
                  },
                  icon: Icon(Icons.share))
            ],
          )
        ],
      ),
    );
  }

  Future saveAndShare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter.png');
    image.writeAsBytesSync(bytes);
    await Share.shareFiles([image.path]);
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '_')
        .replaceAll(':', '_');
    final name = "screenshot_$time";
    final result = await ImageGallerySaver.saveImage(bytes, name: name);

    return result['filePath'];
  }
}
