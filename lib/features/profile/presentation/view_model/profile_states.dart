import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/config/entities/user_entity.dart';

class ProfileStates {
  final BaseState<UserEntity>? profileState;
  final BaseState<UserEntity>? updateState;
  final bool isLoggedOut;

  ProfileStates({
    this.profileState,
    this.updateState,
    this.isLoggedOut = false,
  });

  ProfileStates copyWith({
    BaseState<UserEntity>? profileState,
    BaseState<UserEntity>? updateState,
    bool? isLoggedOut,
  }) {
    return ProfileStates(
      profileState: profileState ?? this.profileState,
      updateState: updateState ?? this.updateState,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }
}