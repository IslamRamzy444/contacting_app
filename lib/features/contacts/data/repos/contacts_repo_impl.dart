import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';
import 'package:contacting_app/config/models/contact_model.dart';
import 'package:contacting_app/features/contacts/data/data_sources/remote/contacts_remote_data_source_contract.dart';
import 'package:contacting_app/features/contacts/domain/repos/contacts_repo_contract.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: ContactsRepoContract)
class ContactsRepoImpl implements ContactsRepoContract{
  final ContactsRemoteDataSourceContract _dataSourceContract;
  ContactsRepoImpl(this._dataSourceContract);

  @override
  BaseResponse<Stream<List<ContactEntity>>> getContacts() {
    final response=_dataSourceContract.getContacts();
    switch (response) {
      case SuccessResponse<Stream<List<ContactModel>>>():
        final entityStream = response.data.map((models) {
          return models.map((model) => model.toEntity()).toList();
        });
        return SuccessResponse<Stream<List<ContactEntity>>>(data: entityStream);
      case ErrorResponse<Stream<List<ContactModel>>>():
        return ErrorResponse<Stream<List<ContactEntity>>>(
          error: response.error,
        );
    }
  }
  
}