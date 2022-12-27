import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_miner/helper/firestore_helper.dart';
import 'package:flutter/material.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final GlobalKey<FormState> controller = GlobalKey<FormState>();

  TextEditingController titlecontroller = TextEditingController();
  TextEditingController titleUpdatecontroller = TextEditingController();
  TextEditingController bodycontroller = TextEditingController();
  TextEditingController bodyUpdatecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Note App"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('favorite_page');
              },
              icon: Icon(
                Icons.favorite_rounded,
                color: Colors.red,
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            titlecontroller.clear();
            bodycontroller.clear();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Center(child: Text("Add Note")),
                  content: StreamBuilder(
                    stream: FireStoreHelper.fireStoreHelper.fecthchCount(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("Error : ${snapshot.error}"));
                      } else if (snapshot.hasData) {
                        QuerySnapshot? querySnapshort = snapshot.data;
                        List<QueryDocumentSnapshot> allDocs =
                            querySnapshort!.docs;
                        int count = allDocs[0]['count'];
                        count = ++count;
                        return SingleChildScrollView(
                          child: Form(
                            key: controller,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Id : $count"),
                                SizedBox(height: 20),
                                TextFormField(
                                    controller: titlecontroller,
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return "Enter You Valid Title";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        label: Text("Title"),
                                        hintText: "Enter Note Title")),
                                SizedBox(height: 20),
                                TextFormField(
                                    controller: bodycontroller,
                                    maxLines: 3,
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return "Enter You Valid Body";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        label: Text("Body"),
                                        hintText: "Enter Note Body")),
                                SizedBox(height: 20),
                                ElevatedButton(
                                    onPressed: () {
                                      if (controller.currentState!.validate()) {
                                        Map<String, dynamic> data = {
                                          "id": count,
                                          "Title": titlecontroller.text,
                                          "Body": bodycontroller.text,
                                          "favorite": false,
                                        };
                                        Map<String, dynamic> data2 = {
                                          "count": count,
                                        };
                                        FireStoreHelper.fireStoreHelper
                                            .insertData(
                                                name: "note_data", data: data);
                                        FireStoreHelper.fireStoreHelper
                                            .UpdateCount(
                                                data: data2,
                                                name: "note_count");
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "New Note Successfuly......"),
                                                backgroundColor: Colors.green,
                                                behavior:
                                                    SnackBarBehavior.floating));
                                        titlecontroller.clear();
                                        bodycontroller.clear();
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Text("Save"))
                              ],
                            ),
                          ),
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                );
              },
            );
          },
          child: Icon(Icons.add)),
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
            for (int i = 0; i < allDocs.length; i++) {
              allData.add(allDocs[i].data());
            }
            return ListView.builder(
              itemCount: allData.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:
                            ([...Colors.primaries]..shuffle()).first.shade200),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 10),
                            Center(
                                child: Text(
                              "${allData[i]['Title']}",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            )),
                            Divider(thickness: 4),
                            Center(
                                child: Text(
                              "${allData[i]['Body']}",
                              style: TextStyle(fontSize: 20),
                            )),
                            SizedBox(height: 20),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      titleUpdatecontroller.text =
                                          "${allData[i]['Title']}";
                                      bodyUpdatecontroller.text =
                                          "${allData[i]['Body']}";
                                      return AlertDialog(
                                        title:
                                            Center(child: Text("Edite Note")),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                                controller:
                                                    titleUpdatecontroller,
                                                decoration: InputDecoration(
                                                    label: Text("Title"),
                                                    border:
                                                        OutlineInputBorder())),
                                            SizedBox(height: 20),
                                            TextFormField(
                                                maxLines: 3,
                                                controller:
                                                    bodyUpdatecontroller,
                                                decoration: InputDecoration(
                                                    label: Text("Body"),
                                                    border:
                                                        OutlineInputBorder())),
                                          ],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Map<String, dynamic> data = {
                                                  "Title": titleUpdatecontroller
                                                      .text,
                                                  "Body":
                                                      bodyUpdatecontroller.text
                                                };
                                                FireStoreHelper.fireStoreHelper
                                                    .UpdateRecode(
                                                        id: allData[i]['id']
                                                            .toString(),
                                                        data: data,
                                                        name: "note_data");
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            "You Note Update Successfuly..........."),
                                                        backgroundColor:
                                                            Colors.green,
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
                                                FireStoreHelper.fireStoreHelper
                                                    .DeleteRecode(
                                                        id: allData[i]['id']
                                                            .toString(),
                                                        data: allData[i],
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
                                    bool favorite = allData[i]['favorite'];
                                    favorite = !favorite;
                                    Map<String, dynamic> data = {
                                      "id": allData[i]['id'],
                                      "Title": allData[i]['Title'],
                                      "favorite": favorite,
                                    };
                                    FireStoreHelper.fireStoreHelper
                                        .UpdateRecode(
                                            id: allData[i]['id'].toString(),
                                            data: data,
                                            name: "note_data");
                                  });
                                },
                                icon: Icon(
                                  (allData[i]['favorite'])
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
      ),
    );
  }
}

//
