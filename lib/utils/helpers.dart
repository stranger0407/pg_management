import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Helpers {
  static const _uuid = Uuid();

  static String generateId() => _uuid.v4();

  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final timePart = DateFormat('HHmmss').format(now);
    return 'INV-$datePart-$timePart';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2024, month));
  }

  static String getMonthYear(int month, int year) {
    return '${getMonthName(month)} $year';
  }

  static double calculateLateFine({
    required DateTime paymentDate,
    required int rentDueDay,
    required double finePerDay,
  }) {
    final dueDate = DateTime(paymentDate.year, paymentDate.month, rentDueDay);
    if (paymentDate.isAfter(dueDate)) {
      final daysLate = paymentDate.difference(dueDate).inDays;
      return daysLate * finePerDay;
    }
    return 0.0;
  }
}
