import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacting_app/config/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String? name;
  final String email;
  final String? photoUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  UserModel({
    required this.id,
    this.name,
    required this.email,
    this.photoUrl,
    this.isOnline = false,
    this.lastSeen,
  });
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      name: user.displayName,
      email: user.email ?? '',
      photoUrl: user.photoURL,
      isOnline: true,
    );
  }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'] ?? json['id'] ?? '',
      name: json['name'],
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null? (json['lastSeen'] as Timestamp).toDate(): null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      isOnline: isOnline,
      lastSeen: lastSeen,
    );
  }
}