import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/user_entity.dart';
import 'package:contacting_app/config/models/user_model.dart';
import 'package:contacting_app/features/auth/register/data/data_sources/remote/register_remote_data_source_contract.dart';
import 'package:contacting_app/features/auth/register/domain/repos/register_repo_contract.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: RegisterRepoContract)
class RegisterRepoImpl implements RegisterRepoContract{
  final RegisterRemoteDataSourceContract _dataSourceContract;
  RegisterRepoImpl(this._dataSourceContract);
  @override
  Future<BaseResponse<UserEntity>> register({required String name, required String email, required String password}) async{
    final response=await _dataSourceContract.registerWithEmailAndPassword(name: name, email: email, password: password);
    switch(response){
      
      case SuccessResponse<UserModel>():
        return SuccessResponse<UserEntity>(data: response.data.toEntity());
      case ErrorResponse<UserModel>():
        return ErrorResponse<UserEntity>(error: response.error);
    }
  }

}