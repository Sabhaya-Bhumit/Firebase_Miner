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
    return Scaffold(
        appBar: AppBar(title: Text("Favorite Page")),
        backgroundColor: Colors.black,
        body: StreamBuilder(
          stream:
              FireStoreHelper.fireStoreHelper.fecthchAllData(name: "note_data"),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error : ${snapshot.error}"));
            } else if (snapshot.hasData) {
              QuerySnapshot? querySnapshort = snapshot.data;
              List<QueryDocumentSnapshot> allDocs = querySnapshort!.docs;
              List allData = [];
              List favorite = [];
              for (int i = 0; i < allDocs.length; i++) {
                allData.add(allDocs[i].data());
                if (allData[i]['favorite'] == true) {
                  favorite.add(allData[i]);
                }
              }
              return ListView.builder(
                itemCount: favorite.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: ([...Colors.primaries]..shuffle())
                              .first
                              .shade200),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 10),
                              Center(
                                  child: Text(
                                "${favorite[i]['Title']}",
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              )),
                              Divider(thickness: 4),
                              Center(
                                  child: Text(
                                "${favorite[i]['Body']}",
                                style: TextStyle(fontSize: 20),
                              )),
                              SizedBox(height: 20),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                  onPressed: () {},
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
                                                          id: favorite[i]['id']
                                                              .toString(),
                                                          data: favorite[i],
                                                          name: "note_data");
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
                                      bool favorite1 = favorite[i]['favorite'];
                                      favorite1 = !favorite1;
                                      Map<String, dynamic> data = {
                                        "id": favorite[i]['id'],
                                        "Title": favorite[i]['Title'],
                                        "favorite": favorite1,
                                      };
                                      FireStoreHelper.fireStoreHelper
                                          .UpdateRecode(
                                              id: favorite[i]['id'].toString(),
                                              data: data,
                                              name: "note_data");
                                    });
                                  },
                                  icon: Icon(
                                    (favorite[i]['favorite'])
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border,
                                    color: Colors.redAccent,
                                  )),
                            ],
                          )
                        ],
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
