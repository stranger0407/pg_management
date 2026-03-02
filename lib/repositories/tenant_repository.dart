import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tenant.dart';
import '../services/firestore_service.dart';

class TenantRepository {
  final FirestoreService _firestoreService;
  final String buildingId;

  TenantRepository(this._firestoreService, this.buildingId);

  Stream<List<Tenant>> getTenants() {
    return _firestoreService
        .getCollectionStream(
          _firestoreService.tenantsCollection(buildingId),
          orderBy: 'createdAt',
          descending: true,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Tenant.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<Tenant>> getActiveTenants() {
    return _firestoreService.tenantsCollection(buildingId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Tenant.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<String> addTenant(Tenant tenant) async {
    final docRef = await _firestoreService.addDocument(
      _firestoreService.tenantsCollection(buildingId),
      tenant.toMap(),
    );
    // Mark the room as occupied
    await _firestoreService.updateDocument(
      _firestoreService.roomsCollection(buildingId).doc(tenant.roomId),
      {'isOccupied': true},
    );
    return docRef.id;
  }

  Future<void> updateTenant(Tenant tenant) async {
    await _firestoreService.updateDocument(
      _firestoreService.tenantsCollection(buildingId).doc(tenant.tenantId),
      tenant.toMap(),
    );
  }

  Future<void> deactivateTenant(Tenant tenant) async {
    await _firestoreService.updateDocument(
      _firestoreService.tenantsCollection(buildingId).doc(tenant.tenantId),
      {'isActive': false},
    );
    // Check if any other active tenants are in this room
    final roomTenants = await _firestoreService
        .tenantsCollection(buildingId)
        .where('roomId', isEqualTo: tenant.roomId)
        .where('isActive', isEqualTo: true)
        .get();
    if (roomTenants.docs.isEmpty) {
      await _firestoreService.updateDocument(
        _firestoreService.roomsCollection(buildingId).doc(tenant.roomId),
        {'isOccupied': false},
      );
    }
  }

  Future<void> deleteTenant(String tenantId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.tenantsCollection(buildingId).doc(tenantId),
    );
  }
}
