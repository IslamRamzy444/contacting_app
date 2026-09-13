import 'package:contacting_app/config/entities/contact_entity.dart';

class ContactModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isOnline;
  ContactModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isOnline = false,
  });
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['uid'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      isOnline: json['isOnline'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
    };
  }
  ContactEntity toEntity() {
    return ContactEntity(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      isOnline: isOnline,
    );
  }
}