import 'package:contacting_app/features/home/presentation/view_model/home_events.dart';
import 'package:contacting_app/features/home/presentation/view_model/home_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
@injectable
class HomeViewModel extends Cubit<HomeStates>{
  HomeViewModel():super(HomeStates());
  void doIntent(HomeEvents event) {
    if (isClosed) return;

    switch (event) {
      case ChangeTabEvent():
        _changeTab(event);
    }
  }
  void _changeTab(ChangeTabEvent event) {
    emit(state.copyWith(selectedTab: event.tab));
  }
}