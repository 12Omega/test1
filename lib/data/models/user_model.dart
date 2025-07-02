// lib/data/models/user_model.dart
import 'dart:convert';
import 'package:smart_parking_app/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final DateTime? lastLoginAt;

  const UserModel({
    required String uid,
    required String email,
    required String name,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    bool isVerified = false,
    this.lastLoginAt,
  }) : super(
    uid: uid,
    email: email,
    name: name,
    phone: phone,
    photoUrl: photoUrl,
    createdAt: createdAt,
    isVerified: isVerified,
  );

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'isVerified': isVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      isVerified: map['isVerified'] ?? false,
      lastLoginAt: map['lastLoginAt'] != null ? DateTime.parse(map['lastLoginAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      isVerified: entity.isVerified,
      lastLoginAt: null, // lastLoginAt is not part of UserEntity
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    bool? isVerified,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  // Convert to entity
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      createdAt: createdAt,
      isVerified: isVerified,
    );
  }
}
