import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';
import '../services/firestore_service.dart';

class PaymentRepository {
  final FirestoreService _firestoreService;
  final String buildingId;

  PaymentRepository(this._firestoreService, this.buildingId);

  Stream<List<Payment>> getPayments() {
    return _firestoreService
        .getCollectionStream(
          _firestoreService.paymentsCollection(buildingId),
          orderBy: 'createdAt',
          descending: true,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<String> addPayment(Payment payment) async {
    final docRef = await _firestoreService.addDocument(
      _firestoreService.paymentsCollection(buildingId),
      payment.toMap(),
    );
    return docRef.id;
  }

  Future<void> updatePayment(Payment payment) async {
    await _firestoreService.updateDocument(
      _firestoreService.paymentsCollection(buildingId).doc(payment.paymentId),
      payment.toMap(),
    );
  }

  Future<void> deletePayment(String paymentId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.paymentsCollection(buildingId).doc(paymentId),
    );
  }
}
