import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import 'building_provider.dart';

final expenseRepositoryProvider =
    Provider.family<ExpenseRepository, String>((ref, buildingId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ExpenseRepository(firestoreService, buildingId);
});

final expensesStreamProvider =
    StreamProvider.family<List<Expense>, String>((ref, buildingId) {
  final repo = ref.watch(expenseRepositoryProvider(buildingId));
  return repo.getExpenses();
});
