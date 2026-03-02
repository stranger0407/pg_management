import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/building.dart';
import '../../models/payment.dart';
import '../../services/invoice_service.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Building building;
  final Payment payment;

  const InvoicePreviewScreen({
    super.key,
    required this.building,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save PDF',
            onPressed: () => _savePdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => _sharePdf(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => InvoiceService.generateInvoice(
          building: building,
          payment: payment,
        ),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName:
            'Invoice_${payment.invoiceNumber}_${payment.tenantName}.pdf',
      ),
    );
  }

  Future<void> _savePdf(BuildContext context) async {
    try {
      final bytes = await InvoiceService.generateInvoice(
        building: building,
        payment: payment,
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/Invoice_${payment.invoiceNumber}.pdf');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invoice saved to ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving invoice: $e')),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final bytes = await InvoiceService.generateInvoice(
        building: building,
        payment: payment,
      );

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/Invoice_${payment.invoiceNumber}.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Invoice ${payment.invoiceNumber} - ${payment.tenantName}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing invoice: $e')),
        );
      }
    }
  }
}
