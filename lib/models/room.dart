import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String roomId;
  final String roomNumber;
  final int floor;
  final double rentAmount;
  final bool isOccupied;
  final int capacity;
  final DateTime createdAt;

  Room({
    required this.roomId,
    required this.roomNumber,
    this.floor = 0,
    required this.rentAmount,
    this.isOccupied = false,
    this.capacity = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Room.fromMap(Map<String, dynamic> map, String id) {
    return Room(
      roomId: id,
      roomNumber: map['roomNumber'] ?? '',
      floor: map['floor'] ?? 0,
      rentAmount: (map['rentAmount'] ?? 0.0).toDouble(),
      isOccupied: map['isOccupied'] ?? false,
      capacity: map['capacity'] ?? 1,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomNumber': roomNumber,
      'floor': floor,
      'rentAmount': rentAmount,
      'isOccupied': isOccupied,
      'capacity': capacity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Room copyWith({
    String? roomId,
    String? roomNumber,
    int? floor,
    double? rentAmount,
    bool? isOccupied,
    int? capacity,
    DateTime? createdAt,
  }) {
    return Room(
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      floor: floor ?? this.floor,
      rentAmount: rentAmount ?? this.rentAmount,
      isOccupied: isOccupied ?? this.isOccupied,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
