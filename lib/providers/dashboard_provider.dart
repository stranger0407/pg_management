import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import '../models/expense.dart';
import '../providers/payment_provider.dart';
import '../providers/expense_provider.dart';

class DashboardData {
  final double monthlyIncome;
  final double monthlyExpense;
  final double netProfit;
  final double pendingRent;
  final List<MonthlyProfit> profitHistory;

  DashboardData({
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.netProfit,
    required this.pendingRent,
    required this.profitHistory,
  });
}

class MonthlyProfit {
  final int month;
  final int year;
  final double income;
  final double expense;
  final double profit;

  MonthlyProfit({
    required this.month,
    required this.year,
    required this.income,
    required this.expense,
    required this.profit,
  });
}

final dashboardProvider =
    Provider.family<DashboardData, ({String buildingId, List<Payment> payments, List<Expense> expenses})>(
        (ref, params) {
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  // Current month income (paid payments)
  final monthlyIncome = params.payments
      .where((p) =>
          p.month == currentMonth && p.year == currentYear && p.isPaid)
      .fold<double>(0.0, (sum, p) => sum + p.totalAmount);

  // Current month expenses
  final monthlyExpense = params.expenses
      .where(
          (e) => e.date.month == currentMonth && e.date.year == currentYear)
      .fold<double>(0.0, (sum, e) => sum + e.amount);

  // Pending rent (unpaid payments for current month)
  final pendingRent = params.payments
      .where((p) =>
          p.month == currentMonth && p.year == currentYear && !p.isPaid)
      .fold<double>(0.0, (sum, p) => sum + p.totalAmount);

  final netProfit = monthlyIncome - monthlyExpense;

  // 6-month profit history
  final profitHistory = <MonthlyProfit>[];
  for (int i = 5; i >= 0; i--) {
    final date = DateTime(currentYear, currentMonth - i, 1);
    final m = date.month;
    final y = date.year;

    final income = params.payments
        .where((p) => p.month == m && p.year == y && p.isPaid)
        .fold<double>(0.0, (sum, p) => sum + p.totalAmount);

    final expense = params.expenses
        .where((e) => e.date.month == m && e.date.year == y)
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    profitHistory.add(MonthlyProfit(
      month: m,
      year: y,
      income: income,
      expense: expense,
      profit: income - expense,
    ));
  }

  return DashboardData(
    monthlyIncome: monthlyIncome,
    monthlyExpense: monthlyExpense,
    netProfit: netProfit,
    pendingRent: pendingRent,
    profitHistory: profitHistory,
  );
});
