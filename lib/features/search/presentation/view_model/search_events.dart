sealed class SearchEvents {}
class SearchQueryChangedEvent extends SearchEvents {
  final String query;
  SearchQueryChangedEvent(this.query);
}
class LoadSearchContactsEvent extends SearchEvents {
  final String currentUserId;
  LoadSearchContactsEvent(this.currentUserId);
}
class ClearSearchEvent extends SearchEvents {}