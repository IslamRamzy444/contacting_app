import 'package:contacting_app/config/base_state/base_state.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';

class ContactsStates {
  final BaseState<List<ContactEntity>>? contactsState;
  ContactsStates({this.contactsState});
  ContactsStates copyWith({BaseState<List<ContactEntity>>? contactsState}) {
    return ContactsStates(
      contactsState: contactsState ?? this.contactsState,
    );
  }
}