import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String paymentId;
  final String tenantId;
  final String tenantName;
  final String roomId;
  final String roomNumber;
  final double amount;
  final double lateFine;
  final double totalAmount;
  final int month;
  final int year;
  final DateTime paymentDate;
  final int rentDueDay;
  final bool isPaid;
  final String invoiceNumber;
  final DateTime createdAt;

  Payment({
    required this.paymentId,
    required this.tenantId,
    required this.tenantName,
    required this.roomId,
    required this.roomNumber,
    required this.amount,
    this.lateFine = 0.0,
    required this.totalAmount,
    required this.month,
    required this.year,
    required this.paymentDate,
    this.rentDueDay = 1,
    this.isPaid = false,
    this.invoiceNumber = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Payment.fromMap(Map<String, dynamic> map, String id) {
    return Payment(
      paymentId: id,
      tenantId: map['tenantId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      roomId: map['roomId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      lateFine: (map['lateFine'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      month: map['month'] ?? 1,
      year: map['year'] ?? DateTime.now().year,
      paymentDate: map['paymentDate'] is Timestamp
          ? (map['paymentDate'] as Timestamp).toDate()
          : DateTime.now(),
      rentDueDay: map['rentDueDay'] ?? 1,
      isPaid: map['isPaid'] ?? false,
      invoiceNumber: map['invoiceNumber'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'tenantName': tenantName,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'amount': amount,
      'lateFine': lateFine,
      'totalAmount': totalAmount,
      'month': month,
      'year': year,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'rentDueDay': rentDueDay,
      'isPaid': isPaid,
      'invoiceNumber': invoiceNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Payment copyWith({
    String? paymentId,
    String? tenantId,
    String? tenantName,
    String? roomId,
    String? roomNumber,
    double? amount,
    double? lateFine,
    double? totalAmount,
    int? month,
    int? year,
    DateTime? paymentDate,
    int? rentDueDay,
    bool? isPaid,
    String? invoiceNumber,
    DateTime? createdAt,
  }) {
    return Payment(
      paymentId: paymentId ?? this.paymentId,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      amount: amount ?? this.amount,
      lateFine: lateFine ?? this.lateFine,
      totalAmount: totalAmount ?? this.totalAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      paymentDate: paymentDate ?? this.paymentDate,
      rentDueDay: rentDueDay ?? this.rentDueDay,
      isPaid: isPaid ?? this.isPaid,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
