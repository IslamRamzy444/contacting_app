import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/user_entity.dart';
import 'package:contacting_app/config/models/user_model.dart';
import 'package:contacting_app/features/auth/login/data/data_sources/remote/login_remote_data_source_contract.dart';
import 'package:contacting_app/features/auth/login/domain/repos/login_repo_contract.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: LoginRepoContract)
class LoginRepoImpl implements LoginRepoContract{
  final LoginRemoteDataSourceContract _dataSourceContract;
  LoginRepoImpl(this._dataSourceContract);
  @override
  Future<BaseResponse<UserEntity>> login({required String email, required String password}) async{
    final response=await _dataSourceContract.loginWithEmailAndPassword(email: email, password: password);
    switch(response){
      
      case SuccessResponse<UserModel>():
        return SuccessResponse<UserEntity>(data: response.data.toEntity());
      case ErrorResponse<UserModel>():
        return ErrorResponse<UserEntity>(error: response.error);
    }
  }

}