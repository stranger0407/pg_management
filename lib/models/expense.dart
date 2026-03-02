import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String expenseId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final DateTime createdAt;

  Expense({
    required this.expenseId,
    required this.title,
    required this.amount,
    this.category = 'General',
    required this.date,
    this.description = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      expenseId: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'General',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      description: map['description'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Expense copyWith({
    String? expenseId,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    DateTime? createdAt,
  }) {
    return Expense(
      expenseId: expenseId ?? this.expenseId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
