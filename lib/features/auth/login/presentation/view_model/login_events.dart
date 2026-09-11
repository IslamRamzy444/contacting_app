sealed class LoginEvents {}
class LoginUserEvent extends LoginEvents{
  final String email;
  final String password;
  LoginUserEvent(this.email,this.password);
}
class TogglePasswordVisibilityEvent extends LoginEvents{}