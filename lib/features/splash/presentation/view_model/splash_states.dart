import 'package:contacting_app/config/base_state/base_state.dart';

class SplashStates {
  final BaseState<bool>? authStatusState;

  SplashStates({this.authStatusState});

  SplashStates copyWith({BaseState<bool>? authStatusState}) {
    return SplashStates(
      authStatusState: authStatusState ?? this.authStatusState,
    );
  }
}