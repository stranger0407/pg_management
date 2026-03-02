import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Base path for current user
  DocumentReference get _userDoc => _db.collection('users').doc(_uid);

  // Buildings
  CollectionReference get buildingsCollection =>
      _userDoc.collection('buildings');

  // Subcollections per building
  CollectionReference roomsCollection(String buildingId) =>
      buildingsCollection.doc(buildingId).collection('rooms');

  CollectionReference tenantsCollection(String buildingId) =>
      buildingsCollection.doc(buildingId).collection('tenants');

  CollectionReference paymentsCollection(String buildingId) =>
      buildingsCollection.doc(buildingId).collection('payments');

  CollectionReference expensesCollection(String buildingId) =>
      buildingsCollection.doc(buildingId).collection('expenses');

  // Generic CRUD operations
  Future<DocumentReference> addDocument(
    CollectionReference collection,
    Map<String, dynamic> data,
  ) async {
    return await collection.add(data);
  }

  Future<void> updateDocument(
    DocumentReference docRef,
    Map<String, dynamic> data,
  ) async {
    await docRef.update(data);
  }

  Future<void> deleteDocument(DocumentReference docRef) async {
    await docRef.delete();
  }

  Stream<QuerySnapshot> getCollectionStream(
    CollectionReference collection, {
    String? orderBy,
    bool descending = false,
  }) {
    if (orderBy != null) {
      return collection.orderBy(orderBy, descending: descending).snapshots();
    }
    return collection.snapshots();
  }
}
