import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../repositories/room_repository.dart';
import 'building_provider.dart';

final roomRepositoryProvider =
    Provider.family<RoomRepository, String>((ref, buildingId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return RoomRepository(firestoreService, buildingId);
});

final roomsStreamProvider =
    StreamProvider.family<List<Room>, String>((ref, buildingId) {
  final repo = ref.watch(roomRepositoryProvider(buildingId));
  return repo.getRooms();
});
