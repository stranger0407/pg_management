import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tenant.dart';
import '../../providers/tenant_provider.dart';
import '../../utils/helpers.dart';
import 'add_edit_tenant_screen.dart';
import 'tenant_detail_screen.dart';

class TenantListScreen extends ConsumerWidget {
  final String buildingId;

  const TenantListScreen({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantsStreamProvider(buildingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Tenants')),
      body: tenantsAsync.when(
        data: (tenants) {
          if (tenants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tenants added yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              return _TenantCard(
                tenant: tenant,
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
              builder: (_) => AddEditTenantScreen(buildingId: buildingId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final Tenant tenant;
  final String buildingId;

  const _TenantCard({required this.tenant, required this.buildingId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tenant.isActive
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          child: Icon(
            Icons.person,
            color: tenant.isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          tenant.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Room ${tenant.roomNumber} \u2022 ${tenant.phone}\nJoined: ${Helpers.formatDate(tenant.joinDate)}',
        ),
        isThreeLine: true,
        trailing: Chip(
          label: Text(
            tenant.isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: tenant.isActive ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
          backgroundColor: tenant.isActive
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          side: BorderSide.none,
          padding: EdgeInsets.zero,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TenantDetailScreen(
                tenant: tenant,
                buildingId: buildingId,
              ),
            ),
          );
        },
      ),
    );
  }
}
