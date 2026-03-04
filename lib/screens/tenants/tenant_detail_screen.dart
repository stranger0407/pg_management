import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tenant.dart';
import '../../providers/tenant_provider.dart';
import '../../utils/helpers.dart';
import 'add_edit_tenant_screen.dart';

class TenantDetailScreen extends ConsumerWidget {
  final String tenantId;
  final String buildingId;

  const TenantDetailScreen({
    super.key,
    required this.tenantId,
    required this.buildingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantsStreamProvider(buildingId));

    return tenantsAsync.when(
      data: (tenants) {
        final tenant = tenants
            .where((t) => t.tenantId == tenantId)
            .firstOrNull;
        if (tenant == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tenant')),
            body: const Center(child: Text('Tenant not found')),
          );
        }
        return _buildContent(context, ref, tenant);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Tenant tenant) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tenant.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditTenantScreen(
                    buildingId: buildingId,
                    tenant: tenant,
                  ),
                ),
              );
            },
          ),
          if (tenant.isActive)
            IconButton(
              icon: const Icon(Icons.person_off),
              tooltip: 'Deactivate Tenant',
              onPressed: () => _confirmDeactivate(context, ref, tenant),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tenant.name,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Chip(
              label: Text(tenant.isActive ? 'Active' : 'Inactive'),
              backgroundColor: tenant.isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              side: BorderSide.none,
            ),
            const SizedBox(height: 24),
            // Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _detailRow('Room', 'Room ${tenant.roomNumber}'),
                    _detailRow('Phone', tenant.phone),
                    if (tenant.email.isNotEmpty)
                      _detailRow('Email', tenant.email),
                    _detailRow(
                        'Join Date', Helpers.formatDate(tenant.joinDate)),
                    if (tenant.idProofType.isNotEmpty)
                      _detailRow('ID Type', tenant.idProofType),
                    if (tenant.idProofNumber.isNotEmpty)
                      _detailRow('ID Number', tenant.idProofNumber),
                    if (tenant.emergencyContact.isNotEmpty)
                      _detailRow('Emergency', tenant.emergencyContact),
                    if (tenant.permanentAddress.isNotEmpty)
                      _detailRow('Address', tenant.permanentAddress),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, WidgetRef ref, Tenant tenant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Tenant'),
        content: Text(
            'Mark "${tenant.name}" as inactive? The room will be marked as vacant.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(tenantRepositoryProvider(buildingId))
                    .deactivateTenant(tenant);
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}
