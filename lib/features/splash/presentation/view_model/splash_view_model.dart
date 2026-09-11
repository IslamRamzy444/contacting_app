import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/features/splash/domain/use_cases/get_auth_status_use_case.dart';
import 'package:contacting_app/features/splash/presentation/view_model/splash_events.dart';
import 'package:contacting_app/features/splash/presentation/view_model/splash_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
@injectable
class SplashViewModel extends Cubit<SplashStates>{
  final GetAuthStatusUseCase _useCase;
  SplashViewModel(this._useCase):super(SplashStates());
  void doIntent(SplashEvents event){
    if (isClosed) return;
    switch(event){
      
      case CheckAuthStatusEvent():
        _checkAuthStatus();
    }
  }
  Future<void> _checkAuthStatus()async{
    emit(state.copyWith(
      authStatusState: BaseState<bool>(isLoading: true),
    ));
    await Future.delayed(const Duration(seconds: 2));
    final res=await _useCase.call();
    if (isClosed) return;
    switch(res){
      
      case SuccessResponse<bool>():
        emit(state.copyWith(
          authStatusState: BaseState<bool>(
            isLoading: false,
            data: res.data,
          ),
        ));
      case ErrorResponse<bool>():
        emit(state.copyWith(
          authStatusState: BaseState<bool>(
            isLoading: false,
            errorMessage: res.error.toString(),
          ),
        ));
    }
  }
}