import 'dart:convert';
import 'dart:typed_data';

import 'package:authors_app/helper/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text("Authors App"), actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('favorite');
            },
            icon: Icon(Icons.favorite_rounded, color: Colors.red))
      ]),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('add_book');
          },
          child: Icon(Icons.add, color: Colors.black),
          autofocus: true,
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent),
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
            List image = [];
            for (int i = 0; i < allDocs.length; i++) {
              allData.add(allDocs[i].data());
              Uint8List imageU = base64.decode(allData[i]['image']);
              image.add(imageU);
            }

            return ListView.builder(
              itemCount: allData.length,
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
                                              "Enter ",
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
                                  SizedBox(height: 10),
                                  Text("${allData[i]['book_name']}",
                                      style:
                                          TextStyle(fontSize: _height * 0.032),
                                      textAlign: TextAlign.center),
                                  SizedBox(height: 20),
                                  Divider(
                                      indent: 7,
                                      endIndent: 7,
                                      thickness: 5,
                                      color: Colors.black),
                                  SizedBox(height: 20),
                                  Text("Author Name",
                                      style: TextStyle(
                                          fontSize: _height * 0.034,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text("${allData[i]['author_name']}",
                                      style:
                                          TextStyle(fontSize: _height * 0.032),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.visible),
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
                                        arguments: allData[i]);
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
                                          title:
                                              Text("Do you want to delete it?"),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  FireStoreHelper
                                                      .fireStoreHelper
                                                      .DeleteRecode(
                                                          id: allData[i]['id']
                                                              .toString(),
                                                          data: allData[i],
                                                          name: "books_detail");
                                                  ScaffoldMessenger.of(context)
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
                                      bool favorite = allData[i]['favorite'];
                                      favorite = !favorite;
                                      Map<String, dynamic> data = {
                                        "favorite": favorite,
                                      };
                                      FireStoreHelper.fireStoreHelper
                                          .UpdateRecode(
                                              id: allData[i]['id'].toString(),
                                              data: data,
                                              name: "books_detail");
                                    });
                                  },
                                  icon: Icon(
                                    (allData[i]['favorite'])
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
      ),
    );
  }
}
