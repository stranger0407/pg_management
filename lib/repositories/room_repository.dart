import '../models/room.dart';
import '../services/firestore_service.dart';

class RoomRepository {
  final FirestoreService _firestoreService;
  final String buildingId;

  RoomRepository(this._firestoreService, this.buildingId);

  Stream<List<Room>> getRooms() {
    return _firestoreService
        .getCollectionStream(
          _firestoreService.roomsCollection(buildingId),
          orderBy: 'roomNumber',
        )
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Room.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<String> addRoom(Room room) async {
    final docRef = await _firestoreService.addDocument(
      _firestoreService.roomsCollection(buildingId),
      room.toMap(),
    );
    return docRef.id;
  }

  Future<void> updateRoom(Room room) async {
    await _firestoreService.updateDocument(
      _firestoreService.roomsCollection(buildingId).doc(room.roomId),
      room.toMap(),
    );
  }

  Future<void> deleteRoom(String roomId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.roomsCollection(buildingId).doc(roomId),
    );
  }
}
