import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tenant.dart';
import '../repositories/tenant_repository.dart';
import 'building_provider.dart';

final tenantRepositoryProvider =
    Provider.family<TenantRepository, String>((ref, buildingId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return TenantRepository(firestoreService, buildingId);
});

final tenantsStreamProvider =
    StreamProvider.family<List<Tenant>, String>((ref, buildingId) {
  final repo = ref.watch(tenantRepositoryProvider(buildingId));
  return repo.getTenants();
});

final activeTenantsStreamProvider =
    StreamProvider.family<List<Tenant>, String>((ref, buildingId) {
  final repo = ref.watch(tenantRepositoryProvider(buildingId));
  return repo.getActiveTenants();
});
