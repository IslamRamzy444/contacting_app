enum AppTab {contacts,calls,profile}
class HomeStates {
  final AppTab selectedTab;
  HomeStates({this.selectedTab=AppTab.contacts});
  HomeStates copyWith({AppTab? selectedTab}) {
    return HomeStates(
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}