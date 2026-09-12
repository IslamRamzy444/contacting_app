sealed class ProfileEvents {}
class GetProfileEvent extends ProfileEvents {}
class UpdateProfileEvent extends ProfileEvents {
  final String name;
  final String? photoUrl;
  UpdateProfileEvent({required this.name, this.photoUrl});
}
class LogoutEvent extends ProfileEvents {}