import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../utils/helpers.dart';
import 'add_edit_expense_screen.dart';

class ExpenseListScreen extends ConsumerWidget {
  final String buildingId;

  const ExpenseListScreen({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider(buildingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses recorded yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return _ExpenseCard(
                expense: expense,
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
              builder: (_) => AddEditExpenseScreen(buildingId: buildingId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExpenseCard extends ConsumerWidget {
  final Expense expense;
  final String buildingId;

  const _ExpenseCard({
    required this.expense,
    required this.buildingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditExpenseScreen(
                buildingId: buildingId,
                expense: expense,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getCategoryColor(expense.category)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: _getCategoryColor(expense.category),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            expense.category,
                            style: const TextStyle(fontSize: 11),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                          backgroundColor: _getCategoryColor(expense.category)
                              .withValues(alpha: 0.1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Helpers.formatDate(expense.date),
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                Helpers.formatCurrency(expense.amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Electricity':
        return Colors.amber;
      case 'Water':
        return Colors.blue;
      case 'Maintenance':
        return Colors.orange;
      case 'Cleaning':
        return Colors.teal;
      case 'Repairs':
        return Colors.red;
      case 'Salary':
        return Colors.purple;
      case 'Internet':
        return Colors.indigo;
      case 'Gas':
        return Colors.deepOrange;
      case 'Furniture':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electricity':
        return Icons.bolt;
      case 'Water':
        return Icons.water_drop;
      case 'Maintenance':
        return Icons.build;
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'Repairs':
        return Icons.handyman;
      case 'Salary':
        return Icons.people;
      case 'Internet':
        return Icons.wifi;
      case 'Gas':
        return Icons.local_fire_department;
      case 'Furniture':
        return Icons.chair;
      default:
        return Icons.receipt;
    }
  }
}
