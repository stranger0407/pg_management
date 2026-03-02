import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../providers/building_provider.dart';
import '../../utils/helpers.dart';
import 'invoice_preview_screen.dart';

class InvoiceListScreen extends ConsumerWidget {
  final String buildingId;

  const InvoiceListScreen({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsStreamProvider(buildingId));
    final buildingsAsync = ref.watch(buildingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      body: paymentsAsync.when(
        data: (payments) {
          final paidPayments =
              payments.where((p) => p.isPaid).toList();
          if (paidPayments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No invoices available',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Record paid payments to generate invoices',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: paidPayments.length,
            itemBuilder: (context, index) {
              final payment = paidPayments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.picture_as_pdf,
                        color: Colors.teal),
                  ),
                  title: Text(
                    payment.tenantName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${Helpers.getMonthYear(payment.month, payment.year)} | ${Helpers.formatCurrency(payment.totalAmount)}',
                  ),
                  trailing: Text(
                    payment.invoiceNumber.isNotEmpty
                        ? payment.invoiceNumber
                        : 'N/A',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  onTap: () {
                    buildingsAsync.whenData((buildings) {
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
                      }
                    });
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
