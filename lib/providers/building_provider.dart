import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/building.dart';
import '../repositories/building_repository.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final buildingRepositoryProvider = Provider<BuildingRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return BuildingRepository(firestoreService);
});

final buildingsStreamProvider = StreamProvider<List<Building>>((ref) {
  final repo = ref.watch(buildingRepositoryProvider);
  return repo.getBuildings();
});

final selectedBuildingProvider = StateProvider<Building?>((ref) => null);
