import 'dart:async';

import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';
import 'package:contacting_app/features/contacts/domain/use_cases/get_contacts_use_case.dart';
import 'package:contacting_app/features/search/domain/use_cases/search_use_case.dart';
import 'package:contacting_app/features/search/presentation/view_model/search_events.dart';
import 'package:contacting_app/features/search/presentation/view_model/search_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
@injectable
class SearchViewModel extends Cubit<SearchStates> {
  final SearchUseCase _searchUsersUseCase;
  final GetContactsUseCase _getContactsUseCase;

  StreamSubscription<List<ContactEntity>>? _contactsSub;
  Timer? _debounce;
  String? _currentUserId;

  SearchViewModel(this._searchUsersUseCase, this._getContactsUseCase)
      : super(SearchStates());

  void doIntent(SearchEvents event) {
    if (isClosed) return;
    switch (event) {
      case LoadSearchContactsEvent():
        _subscribeToContacts(event.currentUserId);
      case SearchQueryChangedEvent():
        _onQueryChanged(event.query);
      case ClearSearchEvent():
        _clear();
    }
  }

  void setCurrentUserId(String id) => _currentUserId = id;

  void _subscribeToContacts(String currentUserId) {
    _currentUserId = currentUserId;
    _contactsSub?.cancel();

    emit(state.copyWith(
      allContactsState: BaseState<List<ContactEntity>>(isLoading: true),
    ));

    final response = _getContactsUseCase.call();

    switch (response) {
      case SuccessResponse<Stream<List<ContactEntity>>>():
        _contactsSub = response.data.listen(
          (contacts) {
            if (isClosed) return;
            emit(state.copyWith(
              allContactsState: BaseState<List<ContactEntity>>(
                isLoading: false,
                data: contacts,
              ),
            ));
          },
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(
              allContactsState: BaseState<List<ContactEntity>>(
                isLoading: false,
                errorMessage: e.toString(),
              ),
            ));
          },
        );
      case ErrorResponse<Stream<List<ContactEntity>>>():
        emit(state.copyWith(
          allContactsState: BaseState<List<ContactEntity>>(
            isLoading: false,
            errorMessage: response.error.toString(),
          ),
        ));
    }
  }

  void _onQueryChanged(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      emit(state.copyWith(
        searchState: BaseState<List<ContactEntity>>(isLoading: false, data: []),
      ));
      if (_currentUserId != null && _contactsSub == null) {
        _subscribeToContacts(_currentUserId!);
      }
      return;
    }

    _contactsSub?.cancel();
    _contactsSub = null;

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    emit(state.copyWith(
      searchState: BaseState<List<ContactEntity>>(isLoading: true),
    ));

    final res = await _searchUsersUseCase.call(
      query: query,
      currentUserId: currentUserId,
    );

    if (res is SuccessResponse<List<ContactEntity>> && state.query != query) {
      return;
    }

    switch (res) {
      case SuccessResponse<List<ContactEntity>>():
        emit(state.copyWith(
          searchState: BaseState<List<ContactEntity>>(
            isLoading: false,
            data: res.data,
          ),
        ));
      case ErrorResponse<List<ContactEntity>>():
        emit(state.copyWith(
          searchState: BaseState<List<ContactEntity>>(
            isLoading: false,
            errorMessage: res.error.toString(),
          ),
        ));
    }
  }

  void _clear() {
    _debounce?.cancel();
    _contactsSub?.cancel();
    _contactsSub = null;
    _currentUserId = null;
    emit(SearchStates());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _contactsSub?.cancel();
    return super.close();
  }
}