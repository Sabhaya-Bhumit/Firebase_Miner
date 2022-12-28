import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreHelper {
  FireStoreHelper._();
  static FireStoreHelper fireStoreHelper = FireStoreHelper._();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> insertData(
      {required String name, required Map<String, dynamic> data}) async {
    await firestore.collection("$name").doc("${data['id']}").set(data);
  }

  Stream<QuerySnapshot> fecthchAllData({required String name}) {
    return firestore.collection(name).snapshots();
  }

  Future<void> UpdateRecode(
      {required String id,
      required Map<String, dynamic> data,
      required String name}) async {
    await firestore.collection(name).doc(id).update(data);
  }

  Future<void> DeleteRecode(
      {required String id,
      required Map<String, dynamic> data,
      required String name}) async {
    await firestore.collection(name).doc(id).delete();
  }

  //couter
  Stream<QuerySnapshot> fecthchCount() {
    return firestore.collection("counter").snapshots();
  }

  Future<void> UpdateCount(
      {required Map<String, dynamic> data, required String name}) async {
    await firestore.collection("counter").doc(name).update(data);
  }
}
