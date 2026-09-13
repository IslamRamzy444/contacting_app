class ContactEntity {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isOnline;

  ContactEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isOnline = false,
  });
}