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
        .orderBy('createdAt', descending: true)
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
    // Update room occupancy count and status
    final roomRef =
        _firestoreService.roomsCollection(buildingId).doc(tenant.roomId);
    final roomDoc = await roomRef.get();
    if (roomDoc.exists) {
      final data = roomDoc.data() as Map<String, dynamic>;
      final currentCount = data['occupantCount'] ?? 0;
      final newCount = currentCount + 1;
      final capacity = data['capacity'] ?? 1;
      await roomRef.update({
        'occupantCount': newCount,
        'isOccupied': newCount >= capacity,
      });
    }
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
    // Update room occupancy count
    final roomRef =
        _firestoreService.roomsCollection(buildingId).doc(tenant.roomId);
    final roomTenants = await _firestoreService
        .tenantsCollection(buildingId)
        .where('roomId', isEqualTo: tenant.roomId)
        .where('isActive', isEqualTo: true)
        .get();
    final activeCount = roomTenants.docs.length;
    await roomRef.update({
      'occupantCount': activeCount,
      'isOccupied': activeCount > 0 ? true : false,
    });
  }

  Future<void> deleteTenant(String tenantId) async {
    // Get tenant data before deleting to update room
    final tenantDoc = await _firestoreService
        .tenantsCollection(buildingId)
        .doc(tenantId)
        .get();

    await _firestoreService.deleteDocument(
      _firestoreService.tenantsCollection(buildingId).doc(tenantId),
    );

    // Update room occupancy if tenant data was found
    if (tenantDoc.exists) {
      final data = tenantDoc.data() as Map<String, dynamic>;
      final roomId = data['roomId'] as String?;
      final wasActive = data['isActive'] as bool? ?? true;
      if (roomId != null && wasActive) {
        final roomRef =
            _firestoreService.roomsCollection(buildingId).doc(roomId);
        final roomTenants = await _firestoreService
            .tenantsCollection(buildingId)
            .where('roomId', isEqualTo: roomId)
            .where('isActive', isEqualTo: true)
            .get();
        final activeCount = roomTenants.docs.length;
        await roomRef.update({
          'occupantCount': activeCount,
          'isOccupied': activeCount > 0 ? true : false,
        });
      }
    }
  }
}
