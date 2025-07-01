// lib/models/user.dart
import 'dart:convert';

class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final List<String> favoriteSpots;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    List<String>? favoriteSpots,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.favoriteSpots = favoriteSpots ?? [],
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'favoriteSpots': favoriteSpots,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? map['_id']?.toString() ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      favoriteSpots: List<String>.from(map['favoriteSpots'] ?? []),
      createdAt: map['createdAt'] != null 
        ? DateTime.parse(map['createdAt'])
        : null,
      updatedAt: map['updatedAt'] != null 
        ? DateTime.parse(map['updatedAt'])
        : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    List<String>? favoriteSpots,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      favoriteSpots: favoriteSpots ?? this.favoriteSpots,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, fullName: $fullName, email: $email, phoneNumber: $phoneNumber, favoriteSpots: $favoriteSpots, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}