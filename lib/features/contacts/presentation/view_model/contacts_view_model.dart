import 'dart:async';

import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';
import 'package:contacting_app/features/contacts/domain/use_cases/get_contacts_use_case.dart';
import 'package:contacting_app/features/contacts/presentation/view_model/contacts_events.dart';
import 'package:contacting_app/features/contacts/presentation/view_model/contacts_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
@injectable
class ContactsViewModel extends Cubit<ContactsStates>{
  final GetContactsUseCase _getContactsUseCase;
  StreamSubscription? _contactsSubscription;
  ContactsViewModel(this._getContactsUseCase):super(ContactsStates());
  void doIntent(ContactsEvents event) {
    if (isClosed) return;

    switch (event) {
      case GetContactsEvent():
        _getContacts();
    }
  }

  void _getContacts() {
    _contactsSubscription?.cancel();
    emit(state.copyWith(
      contactsState: BaseState<List<ContactEntity>>(isLoading: true),
    ));
    final response = _getContactsUseCase.call();
    switch (response) {
      case SuccessResponse<Stream<List<ContactEntity>>>():
        _contactsSubscription = response.data.listen(
          (contacts) {
            if (isClosed) return;
            emit(state.copyWith(
              contactsState: BaseState<List<ContactEntity>>(
                isLoading: false,
                data: contacts,
              ),
            ));
          },
          onError: (error) {
            if (isClosed) return;
            emit(state.copyWith(
              contactsState: BaseState<List<ContactEntity>>(
                isLoading: false,
                errorMessage: error.toString(),
              ),
            ));
          },
        );

      case ErrorResponse<Stream<List<ContactEntity>>>():
        emit(state.copyWith(
          contactsState: BaseState<List<ContactEntity>>(
            isLoading: false,
            errorMessage: response.error.toString(),
          ),
        ));
    }
  }
  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    return super.close();
  }
}