import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/models/contact_model.dart';

abstract class ContactsRemoteDataSourceContract {
   BaseResponse<Stream<List<ContactModel>>> getContacts();
}