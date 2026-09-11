import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/config/entities/user_entity.dart';
import 'package:contacting_app/features/auth/register/domain/use_cases/register_use_case.dart';
import 'package:contacting_app/features/auth/register/presentation/view_model/register_events.dart';
import 'package:contacting_app/features/auth/register/presentation/view_model/register_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterViewModel extends Cubit<RegisterStates>{
  final RegisterUseCase _registerUseCase;
  RegisterViewModel(this._registerUseCase):super(RegisterStates());
  void doIntent(RegisterEvents event){
    switch(event){
      
      case RegisterUserEvent():
        _registerUser(event.email, event.name, event.password);
      case TogglePasswordVisibilityEvent():
        _togglePasswordVisibility();
      case ToggleConfirmPasswordVisibilityEvent():
        _toggleConfirmPasswordVisibility();
    }
  }
  Future<void> _registerUser(String email,String name,String password)async{
    emit(state.copyWith(
      registerState: BaseState<UserEntity>(isLoading: true)
    ));
    final res=await _registerUseCase.call(name: name, email: email, password: password);
    switch(res){
      
      case SuccessResponse<UserEntity>():
        emit(state.copyWith(
          registerState: BaseState<UserEntity>(
            isLoading: false,
            data: res.data
          )
        ));
      case ErrorResponse<UserEntity>():
        emit(state.copyWith(
          registerState: BaseState<UserEntity>(
            isLoading: false,
            errorMessage: res.error.toString()
          )
        ));
    }
  }
  void _togglePasswordVisibility(){
    emit(state.copyWith(
      isPasswordHidden: !state.isPasswordHidden!
    ));
  }
  void _toggleConfirmPasswordVisibility(){
    emit(state.copyWith(
      isConfirmPasswordHidden: !state.isConfirmPasswordHidden!
    ));
  }
}