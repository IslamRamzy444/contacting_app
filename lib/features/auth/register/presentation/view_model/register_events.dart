sealed class RegisterEvents {}
class RegisterUserEvent extends RegisterEvents{
  final String email;
  final String name;
  final String password;
  RegisterUserEvent(this.email,this.name,this.password);
}
class TogglePasswordVisibilityEvent extends RegisterEvents{}
class ToggleConfirmPasswordVisibilityEvent extends RegisterEvents{}