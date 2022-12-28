import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../helper/firestore_helper.dart';

class favorite extends StatefulWidget {
  const favorite({Key? key}) : super(key: key);

  @override
  State<favorite> createState() => _favoriteState();
}

class _favoriteState extends State<favorite> {
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: Text("Favorite Page")),
        backgroundColor: Colors.black,
        body: StreamBuilder(
          stream: FireStoreHelper.fireStoreHelper
              .fecthchAllData(name: "books_detail"),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error : ${snapshot.error}"));
            } else if (snapshot.hasData) {
              QuerySnapshot? querySnapshort = snapshot.data;
              List<QueryDocumentSnapshot> allDocs = querySnapshort!.docs;
              List allData = [];
              List favorite = [];
              List image = [];
              for (int i = 0; i < allDocs.length; i++) {
                allData.add(allDocs[i].data());
                if (allData[i]['favorite'] == true) {
                  favorite.add(allData[i]);
                  Uint8List imageU = base64.decode(allData[i]['image']);
                  image.add(imageU);
                }
              }
              return ListView.builder(
                itemCount: favorite.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed('detail_page', arguments: allData[i]);
                      },
                      child: Container(
                        height: _height * 0.35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: ([...Colors.primaries]..shuffle())
                                .first
                                .shade200),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Container(
                                        height: _height * 0.3,
                                        width: _width * 0.29,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 5,
                                            )),
                                        child: (image[i] != null)
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.memory(
                                                  image[i]!,
                                                  height: _height * 0.288,
                                                  width: _width * 0.44,
                                                  fit: BoxFit.fill,
                                                ),
                                              )
                                            : Text(
                                                "Enter You Book Image and 300*400",
                                                style: TextStyle(fontSize: 18),
                                                textAlign: TextAlign.center,
                                              ))),
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),
                                    Text("Book Name",
                                        style: TextStyle(
                                            fontSize: _height * 0.035,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 20),
                                    Text("${favorite[i]['book_name']}",
                                        style: TextStyle(
                                            fontSize: _height * 0.032)),
                                    SizedBox(height: 20),
                                    Divider(
                                      indent: 7,
                                      endIndent: 7,
                                      thickness: 5,
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: 10),
                                    Text("Author Name",
                                        style: TextStyle(
                                            fontSize: _height * 0.034,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text(
                                      "${favorite[i]['author_name']}",
                                      style:
                                          TextStyle(fontSize: _height * 0.032),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ],
                                )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          'edite_book',
                                          arguments: favorite[i]);
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
                                            title: Text(
                                                "Do you want to delete it?"),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    FireStoreHelper
                                                        .fireStoreHelper
                                                        .DeleteRecode(
                                                            id: favorite[i]
                                                                    ['id']
                                                                .toString(),
                                                            data: favorite[i],
                                                            name:
                                                                "books_detail");
                                                    ScaffoldMessenger
                                                            .of(context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "You Note Recode Delete Successfuly..........."),
                                                            backgroundColor:
                                                                Colors.red,
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating));
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
                                        bool favorite1 =
                                            favorite[i]['favorite'];
                                        favorite1 = !favorite1;
                                        Map<String, dynamic> data = {
                                          "favorite": favorite1,
                                        };
                                        FireStoreHelper.fireStoreHelper
                                            .UpdateRecode(
                                                id: favorite[i]['id']
                                                    .toString(),
                                                data: data,
                                                name: "books_detail");
                                      });
                                    },
                                    icon: Icon(
                                      (favorite[i]['favorite'])
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border,
                                      color: Colors.redAccent,
                                    )),
                                IconButton(
                                    onPressed: () {}, icon: Icon(Icons.share))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }
}
