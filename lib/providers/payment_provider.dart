import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import '../repositories/payment_repository.dart';
import 'building_provider.dart';

final paymentRepositoryProvider =
    Provider.family<PaymentRepository, String>((ref, buildingId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return PaymentRepository(firestoreService, buildingId);
});

final paymentsStreamProvider =
    StreamProvider.family<List<Payment>, String>((ref, buildingId) {
  final repo = ref.watch(paymentRepositoryProvider(buildingId));
  return repo.getPayments();
});
