import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';
import 'package:contacting_app/features/search/domain/repos/search_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class SearchUseCase {
  final SearchRepoContract _repoContract;
  SearchUseCase(this._repoContract);
  Future<BaseResponse<List<ContactEntity>>> call({required String query,required String currentUserId}){
    return _repoContract.searchUsers(query: query, currentUserId: currentUserId);
  }
}