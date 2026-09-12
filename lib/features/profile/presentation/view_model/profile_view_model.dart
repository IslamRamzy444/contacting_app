import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/config/entities/user_entity.dart';
import 'package:contacting_app/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:contacting_app/features/profile/domain/use_cases/logout_use_case.dart';
import 'package:contacting_app/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_events.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
@injectable
class ProfileViewModel extends Cubit<ProfileStates>{
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  ProfileViewModel(this._getProfileUseCase,this._updateProfileUseCase,this._logoutUseCase):super(ProfileStates());
  void doIntent(ProfileEvents event){
    if (isClosed) return;
    switch(event){
      
      case GetProfileEvent():
        _getProfile();
      case UpdateProfileEvent():
        _updateProfile(event);
      case LogoutEvent():
        _logout();
    }
  }
  Future<void> _getProfile() async {
    emit(state.copyWith(
      profileState: BaseState<UserEntity>(isLoading: true),
    ));
    final response = await _getProfileUseCase.call();
    if (isClosed) return;
    switch (response) {
      case SuccessResponse<UserEntity>():
        emit(state.copyWith(
          profileState: BaseState<UserEntity>(
            isLoading: false,
            data: response.data,
          ),
        ));
      case ErrorResponse<UserEntity>():
        emit(state.copyWith(
          profileState: BaseState<UserEntity>(
            isLoading: false,
            errorMessage: response.error.toString(),
          ),
        ));
    }
  }

  Future<void> _updateProfile(UpdateProfileEvent event) async {
    emit(state.copyWith(
      updateState: BaseState<UserEntity>(isLoading: true),
    ));
    final response = await _updateProfileUseCase.call(
      name: event.name,
      photoUrl: event.photoUrl,
    );
    if (isClosed) return;
    switch (response) {
      case SuccessResponse<UserEntity>():
        emit(state.copyWith(
          updateState: BaseState<UserEntity>(
            isLoading: false,
            data: response.data,
          ),
          profileState: BaseState<UserEntity>(
            isLoading: false,
            data: response.data,
          ),
        ));
      case ErrorResponse<UserEntity>():
        emit(state.copyWith(
          updateState: BaseState<UserEntity>(
            isLoading: false,
            errorMessage: response.error.toString(),
          ),
        ));
    }
  }

  Future<void> _logout() async {
    final response = await _logoutUseCase.call();
    if (isClosed) return;
    if (response is SuccessResponse<void>) {
      emit(state.copyWith(isLoggedOut: true));
    }
  }
}