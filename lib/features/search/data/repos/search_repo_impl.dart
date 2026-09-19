import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';
import 'package:contacting_app/config/models/contact_model.dart';
import 'package:contacting_app/features/search/data/data_sources/remote/search_remote_data_source_contract.dart';
import 'package:contacting_app/features/search/domain/repos/search_repo_contract.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: SearchRepoContract)
class SearchRepoImpl implements SearchRepoContract{
  final SearchRemoteDataSourceContract _dataSourceContract;
  SearchRepoImpl(this._dataSourceContract);
  @override
  Future<BaseResponse<List<ContactEntity>>> searchUsers({required String query, required String currentUserId}) async{
    final response=await _dataSourceContract.searchUsers(query: query, currentUserId: currentUserId);
    switch(response){
      
      case SuccessResponse<List<ContactModel>>():
        return SuccessResponse<List<ContactEntity>>(data: response.data.map((e) => e.toEntity(),).toList());
      case ErrorResponse<List<ContactModel>>():
        return ErrorResponse<List<ContactEntity>>(error: response.error);
    }
  }

}