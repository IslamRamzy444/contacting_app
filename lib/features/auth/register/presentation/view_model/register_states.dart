import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/config/entities/user_entity.dart';

class RegisterStates {
  BaseState<UserEntity>? registerState;
  bool? isPasswordHidden;
  bool? isConfirmPasswordHidden;
  RegisterStates({this.registerState,this.isPasswordHidden=true,this.isConfirmPasswordHidden=true});
  RegisterStates copyWith({
    BaseState<UserEntity>? registerState,
    bool? isPasswordHidden,
    bool? isConfirmPasswordHidden
  }){
    return RegisterStates(
      registerState: registerState ?? this.registerState,
      isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
      isConfirmPasswordHidden: isConfirmPasswordHidden ?? this.isConfirmPasswordHidden
    );
  }
}