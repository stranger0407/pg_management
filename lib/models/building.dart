import 'package:cloud_firestore/cloud_firestore.dart';

class Building {
  final String buildingId;
  final String buildingName;
  final String address;
  final String phone;
  final String logoUrl;
  final double finePerDay;
  final String gstNumber;
  final int rentDueDay;
  final DateTime createdAt;

  Building({
    required this.buildingId,
    required this.buildingName,
    required this.address,
    required this.phone,
    this.logoUrl = '',
    this.finePerDay = 0.0,
    this.gstNumber = '',
    this.rentDueDay = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Building.fromMap(Map<String, dynamic> map, String id) {
    return Building(
      buildingId: id,
      buildingName: map['buildingName'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      finePerDay: (map['finePerDay'] ?? 0.0).toDouble(),
      gstNumber: map['gstNumber'] ?? '',
      rentDueDay: map['rentDueDay'] ?? 1,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buildingName': buildingName,
      'address': address,
      'phone': phone,
      'logoUrl': logoUrl,
      'finePerDay': finePerDay,
      'gstNumber': gstNumber,
      'rentDueDay': rentDueDay,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Building copyWith({
    String? buildingId,
    String? buildingName,
    String? address,
    String? phone,
    String? logoUrl,
    double? finePerDay,
    String? gstNumber,
    int? rentDueDay,
    DateTime? createdAt,
  }) {
    return Building(
      buildingId: buildingId ?? this.buildingId,
      buildingName: buildingName ?? this.buildingName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      logoUrl: logoUrl ?? this.logoUrl,
      finePerDay: finePerDay ?? this.finePerDay,
      gstNumber: gstNumber ?? this.gstNumber,
      rentDueDay: rentDueDay ?? this.rentDueDay,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
