import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';

abstract class SearchRepoContract {
  Future<BaseResponse<List<ContactEntity>>> searchUsers({required String query,required String currentUserId});
}