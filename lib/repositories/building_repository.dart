import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/building.dart';
import '../services/firestore_service.dart';

class BuildingRepository {
  final FirestoreService _firestoreService;

  BuildingRepository(this._firestoreService);

  Stream<List<Building>> getBuildings() {
    return _firestoreService
        .getCollectionStream(
          _firestoreService.buildingsCollection,
          orderBy: 'createdAt',
          descending: true,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Building.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<String> addBuilding(Building building) async {
    final docRef = await _firestoreService.addDocument(
      _firestoreService.buildingsCollection,
      building.toMap(),
    );
    return docRef.id;
  }

  Future<void> updateBuilding(Building building) async {
    await _firestoreService.updateDocument(
      _firestoreService.buildingsCollection.doc(building.buildingId),
      building.toMap(),
    );
  }

  Future<void> deleteBuilding(String buildingId) async {
    // Delete all subcollections first (Firestore doesn't cascade deletes)
    await _deleteSubcollection(
        _firestoreService.roomsCollection(buildingId));
    await _deleteSubcollection(
        _firestoreService.tenantsCollection(buildingId));
    await _deleteSubcollection(
        _firestoreService.paymentsCollection(buildingId));
    await _deleteSubcollection(
        _firestoreService.expensesCollection(buildingId));

    await _firestoreService.deleteDocument(
      _firestoreService.buildingsCollection.doc(buildingId),
    );
  }

  Future<void> _deleteSubcollection(CollectionReference collection) async {
    final snapshots = await collection.get();
    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}
