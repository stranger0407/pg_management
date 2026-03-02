import 'package:cloud_firestore/cloud_firestore.dart';

class Tenant {
  final String tenantId;
  final String name;
  final String phone;
  final String email;
  final String roomId;
  final String roomNumber;
  final DateTime joinDate;
  final bool isActive;
  final String idProofType;
  final String idProofNumber;
  final String emergencyContact;
  final String permanentAddress;
  final DateTime createdAt;

  Tenant({
    required this.tenantId,
    required this.name,
    required this.phone,
    this.email = '',
    required this.roomId,
    required this.roomNumber,
    required this.joinDate,
    this.isActive = true,
    this.idProofType = '',
    this.idProofNumber = '',
    this.emergencyContact = '',
    this.permanentAddress = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Tenant.fromMap(Map<String, dynamic> map, String id) {
    return Tenant(
      tenantId: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      roomId: map['roomId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      joinDate: map['joinDate'] is Timestamp
          ? (map['joinDate'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
      idProofType: map['idProofType'] ?? '',
      idProofNumber: map['idProofNumber'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '',
      permanentAddress: map['permanentAddress'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'joinDate': Timestamp.fromDate(joinDate),
      'isActive': isActive,
      'idProofType': idProofType,
      'idProofNumber': idProofNumber,
      'emergencyContact': emergencyContact,
      'permanentAddress': permanentAddress,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Tenant copyWith({
    String? tenantId,
    String? name,
    String? phone,
    String? email,
    String? roomId,
    String? roomNumber,
    DateTime? joinDate,
    bool? isActive,
    String? idProofType,
    String? idProofNumber,
    String? emergencyContact,
    String? permanentAddress,
    DateTime? createdAt,
  }) {
    return Tenant(
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      idProofType: idProofType ?? this.idProofType,
      idProofNumber: idProofNumber ?? this.idProofNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
