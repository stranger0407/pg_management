import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../providers/building_provider.dart';
import '../../utils/helpers.dart';
import '../invoice/invoice_preview_screen.dart';
import 'add_payment_screen.dart';

class PaymentListScreen extends ConsumerWidget {
  final String buildingId;

  const PaymentListScreen({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsStreamProvider(buildingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: paymentsAsync.when(
        data: (payments) {
          if (payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No payments recorded yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _PaymentCard(
                payment: payment,
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
              builder: (_) => AddPaymentScreen(buildingId: buildingId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PaymentCard extends ConsumerWidget {
  final Payment payment;
  final String buildingId;

  const _PaymentCard({
    required this.payment,
    required this.buildingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    payment.tenantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    payment.isPaid ? 'Paid' : 'Unpaid',
                    style: TextStyle(
                      color: payment.isPaid
                          ? Colors.green[800]
                          : Colors.red[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: payment.isPaid
                      ? Colors.green[50]
                      : Colors.red[50],
                  side: BorderSide(
                    color: payment.isPaid ? Colors.green : Colors.red,
                    width: 0.5,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.meeting_room, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Room ${payment.roomNumber}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_month, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  Helpers.getMonthYear(payment.month, payment.year),
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rent: ${Helpers.formatCurrency(payment.amount)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (payment.lateFine > 0)
                      Text(
                        'Late Fine: ${Helpers.formatCurrency(payment.lateFine)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red[700],
                        ),
                      ),
                  ],
                ),
                Text(
                  Helpers.formatCurrency(payment.totalAmount),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (payment.isPaid) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final buildingsAsync =
                        ref.read(buildingsStreamProvider);
                    buildingsAsync.when(
                      data: (buildings) {
                        final building = buildings
                            .where((b) => b.buildingId == buildingId)
                            .firstOrNull;
                        if (building != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InvoicePreviewScreen(
                                building: building,
                                payment: payment,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Building data not found')),
                          );
                        }
                      },
                      loading: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Loading building data, please try again...')),
                        );
                      },
                      error: (error, _) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('View Invoice'),
                ),
              ),
            ],
            if (payment.invoiceNumber.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Invoice: ${payment.invoiceNumber}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
