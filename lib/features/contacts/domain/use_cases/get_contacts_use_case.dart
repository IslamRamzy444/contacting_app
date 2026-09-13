import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';
import 'package:contacting_app/features/contacts/domain/repos/contacts_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class GetContactsUseCase {
  final ContactsRepoContract _repoContract;
  GetContactsUseCase(this._repoContract);
  BaseResponse<Stream<List<ContactEntity>>> call(){
    return _repoContract.getContacts();
  }
}