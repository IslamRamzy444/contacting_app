class UserEntity {
  final String id;
  final String? name;
  final String email;
  final String? photoUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  UserEntity({
    required this.id,
    this.name,
    required this.email,
    this.photoUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}