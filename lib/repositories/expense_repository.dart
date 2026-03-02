import '../models/expense.dart';
import '../services/firestore_service.dart';

class ExpenseRepository {
  final FirestoreService _firestoreService;
  final String buildingId;

  ExpenseRepository(this._firestoreService, this.buildingId);

  Stream<List<Expense>> getExpenses() {
    return _firestoreService
        .getCollectionStream(
          _firestoreService.expensesCollection(buildingId),
          orderBy: 'date',
          descending: true,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Expense.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<String> addExpense(Expense expense) async {
    final docRef = await _firestoreService.addDocument(
      _firestoreService.expensesCollection(buildingId),
      expense.toMap(),
    );
    return docRef.id;
  }

  Future<void> updateExpense(Expense expense) async {
    await _firestoreService.updateDocument(
      _firestoreService.expensesCollection(buildingId).doc(expense.expenseId),
      expense.toMap(),
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.expensesCollection(buildingId).doc(expenseId),
    );
  }
}
