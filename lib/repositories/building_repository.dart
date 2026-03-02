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
    await _firestoreService.deleteDocument(
      _firestoreService.buildingsCollection.doc(buildingId),
    );
  }
}
