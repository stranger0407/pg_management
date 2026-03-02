import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment.dart';
import '../../models/tenant.dart';
import '../../providers/payment_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/building_provider.dart';
import '../../providers/room_provider.dart';
import '../../utils/helpers.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  final String buildingId;

  const AddPaymentScreen({super.key, required this.buildingId});

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  Tenant? _selectedTenant;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  double _rentAmount = 0.0;
  double _lateFine = 0.0;
  bool _isPaid = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final tenantsAsync =
        ref.watch(activeTenantsStreamProvider(widget.buildingId));
    final buildingsAsync = ref.watch(buildingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: tenantsAsync.when(
        data: (tenants) {
          if (tenants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No active tenants found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Add tenants first to record payments'),
                ],
              ),
            );
          }
          return _buildForm(context, tenants, buildingsAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildForm(
      BuildContext context, List<Tenant> tenants, AsyncValue buildingsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tenant Dropdown
            DropdownButtonFormField<Tenant>(
              value: _selectedTenant,
              decoration: const InputDecoration(
                labelText: 'Select Tenant',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: tenants.map((tenant) {
                return DropdownMenuItem<Tenant>(
                  value: tenant,
                  child: Text('${tenant.name} (Room ${tenant.roomNumber})'),
                );
              }).toList(),
              onChanged: (tenant) {
                if (tenant != null) {
                  setState(() {
                    _selectedTenant = tenant;
                  });
                  _loadRentAmount(tenant);
                }
              },
              validator: (value) =>
                  value == null ? 'Please select a tenant' : null,
            ),
            const SizedBox(height: 16),

            // Month & Year Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(12, (i) {
                      return DropdownMenuItem<int>(
                        value: i + 1,
                        child: Text(Helpers.getMonthName(i + 1)),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMonth = value;
                        });
                        _recalculateFine();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(5, (i) {
                      final year = DateTime.now().year - 2 + i;
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedYear = value;
                        });
                        _recalculateFine();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _summaryRow(
                        'Rent Amount', Helpers.formatCurrency(_rentAmount)),
                    if (_lateFine > 0)
                      _summaryRow(
                          'Late Fine', Helpers.formatCurrency(_lateFine),
                          color: Colors.red),
                    const Divider(),
                    _summaryRow(
                      'Total',
                      Helpers.formatCurrency(_rentAmount + _lateFine),
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Paid Toggle
            SwitchListTile(
              title: const Text('Mark as Paid'),
              subtitle:
                  Text(_isPaid ? 'Payment received' : 'Payment pending'),
              value: _isPaid,
              onChanged: (value) {
                setState(() {
                  _isPaid = value;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePayment,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Payment',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
              )),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _loadRentAmount(Tenant tenant) {
    final roomsAsync = ref.read(roomsStreamProvider(widget.buildingId));
    roomsAsync.whenData((rooms) {
      final room = rooms.where((r) => r.roomId == tenant.roomId).firstOrNull;
      if (room != null) {
        setState(() {
          _rentAmount = room.rentAmount;
        });
        _recalculateFine();
      }
    });
  }

  void _recalculateFine() {
    final buildingsAsync = ref.read(buildingsStreamProvider);
    buildingsAsync.whenData((buildings) {
      final building = buildings
          .where((b) => b.buildingId == widget.buildingId)
          .firstOrNull;
      if (building != null) {
        final now = DateTime.now();
        final fine = Helpers.calculateLateFine(
          paymentDate: now,
          rentDueDay: building.rentDueDay,
          finePerDay: building.finePerDay,
        );
        setState(() {
          _lateFine = fine;
        });
      }
    });
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTenant == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tenant = _selectedTenant!;
      final total = _rentAmount + _lateFine;
      final invoiceNumber = Helpers.generateInvoiceNumber();

      final buildingsAsync = ref.read(buildingsStreamProvider);
      int rentDueDay = 1;
      buildingsAsync.whenData((buildings) {
        final building = buildings
            .where((b) => b.buildingId == widget.buildingId)
            .firstOrNull;
        if (building != null) {
          rentDueDay = building.rentDueDay;
        }
      });

      final payment = Payment(
        paymentId: '',
        tenantId: tenant.tenantId,
        tenantName: tenant.name,
        roomId: tenant.roomId,
        roomNumber: tenant.roomNumber,
        amount: _rentAmount,
        lateFine: _lateFine,
        totalAmount: total,
        month: _selectedMonth,
        year: _selectedYear,
        paymentDate: DateTime.now(),
        rentDueDay: rentDueDay,
        isPaid: _isPaid,
        invoiceNumber: invoiceNumber,
      );

      await ref
          .read(paymentRepositoryProvider(widget.buildingId))
          .addPayment(payment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
