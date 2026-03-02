import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/building.dart';
import '../../providers/building_provider.dart';
import '../../utils/helpers.dart';
import '../rooms/room_list_screen.dart';
import '../tenants/tenant_list_screen.dart';
import '../payments/payment_list_screen.dart';
import '../expenses/expense_list_screen.dart';
import 'add_edit_building_screen.dart';

class BuildingDetailScreen extends ConsumerWidget {
  final Building building;

  const BuildingDetailScreen({super.key, required this.building});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(building.buildingName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditBuildingScreen(building: building),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Building Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.apartment,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            building.buildingName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _infoRow(Icons.location_on, building.address),
                    if (building.phone.isNotEmpty)
                      _infoRow(Icons.phone, building.phone),
                    _infoRow(Icons.calendar_today,
                        'Rent due day: ${building.rentDueDay}'),
                    _infoRow(Icons.money,
                        'Late fine: ${Helpers.formatCurrency(building.finePerDay)}/day'),
                    if (building.gstNumber.isNotEmpty)
                      _infoRow(Icons.receipt_long, 'GST: ${building.gstNumber}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Navigation Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _navCard(
                    context,
                    icon: Icons.meeting_room,
                    label: 'Rooms',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RoomListScreen(buildingId: building.buildingId),
                        ),
                      );
                    },
                  ),
                  _navCard(
                    context,
                    icon: Icons.people,
                    label: 'Tenants',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TenantListScreen(buildingId: building.buildingId),
                        ),
                      );
                    },
                  ),
                  _navCard(
                    context,
                    icon: Icons.payment,
                    label: 'Payments',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaymentListScreen(buildingId: building.buildingId),
                        ),
                      );
                    },
                  ),
                  _navCard(
                    context,
                    icon: Icons.receipt,
                    label: 'Expenses',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExpenseListScreen(buildingId: building.buildingId),
                        ),
                      );
                    },
                  ),
                  _navCard(
                    context,
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    color: Colors.purple,
                    onTap: () {
                      // Will be connected in PR 8
                    },
                  ),
                  _navCard(
                    context,
                    icon: Icons.picture_as_pdf,
                    label: 'Invoices',
                    color: Colors.teal,
                    onTap: () {
                      // Will be connected in PR 9
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _navCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Building'),
        content: Text(
            'Are you sure you want to delete "${building.buildingName}"? This will also delete all rooms, tenants, payments, and expenses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(buildingRepositoryProvider)
                  .deleteBuilding(building.buildingId);
              if (context.mounted) Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
