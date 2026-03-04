import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/room.dart';
import '../../providers/room_provider.dart';
import '../../utils/helpers.dart';
import 'add_edit_room_screen.dart';

class RoomListScreen extends ConsumerWidget {
  final String buildingId;

  const RoomListScreen({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsStreamProvider(buildingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.meeting_room, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No rooms added yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _RoomCard(
                room: room,
                buildingId: buildingId,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditRoomScreen(buildingId: buildingId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RoomCard extends ConsumerWidget {
  final Room room;
  final String buildingId;

  const _RoomCard({required this.room, required this.buildingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: room.isOccupied
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.meeting_room,
            color: room.isOccupied ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          'Room ${room.roomNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Floor ${room.floor} \u2022 ${Helpers.formatCurrency(room.rentAmount)}/month \u2022 ${room.occupantCount}/${room.capacity} beds',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                room.isFull ? 'Full' : (room.occupantCount > 0 ? '${room.occupantCount}/${room.capacity}' : 'Vacant'),
                style: TextStyle(
                  color: room.isFull ? Colors.red : Colors.green,
                  fontSize: 12,
                ),
              ),
              backgroundColor: room.isFull
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditRoomScreen(
                        buildingId: buildingId,
                        room: room,
                      ),
                    ),
                  );
                } else if (value == 'delete') {
                  if (room.occupantCount > 0) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Cannot delete an occupied room. Remove tenants first.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Room'),
                      content: Text(
                          'Delete Room ${room.roomNumber}? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    try {
                      await ref
                          .read(roomRepositoryProvider(buildingId))
                          .deleteRoom(room.roomId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Room deleted successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting room: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
