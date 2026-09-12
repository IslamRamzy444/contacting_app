import 'package:contacting_app/features/home/presentation/view_model/home_states.dart';

sealed class HomeEvents {}
class ChangeTabEvent extends HomeEvents {
  final AppTab tab;
  ChangeTabEvent(this.tab);
}