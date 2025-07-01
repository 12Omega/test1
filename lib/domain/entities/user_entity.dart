// lib/domain/entities/user_entity.dart
class UserEntity {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool isVerified;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    this.createdAt,
    this.isVerified = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserEntity && 
      other.uid == uid &&
      other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;
}