import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';

abstract class ContactsRepoContract {
   BaseResponse<Stream<List<ContactEntity>>> getContacts();
}