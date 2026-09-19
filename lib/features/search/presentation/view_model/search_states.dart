import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';

class SearchStates {
  BaseState<List<ContactEntity>>? searchState;
  BaseState<List<ContactEntity>>? allContactsState;
  String query;

  SearchStates({
    this.searchState,
    this.allContactsState,
    this.query = '',
  });

  SearchStates copyWith({
    BaseState<List<ContactEntity>>? searchState,
    BaseState<List<ContactEntity>>? allContactsState,
    String? query,
  }) {
    return SearchStates(
      searchState: searchState ?? this.searchState,
      allContactsState: allContactsState ?? this.allContactsState,
      query: query ?? this.query,
    );
  }
}