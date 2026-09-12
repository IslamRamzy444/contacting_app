import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/user_entity.dart';
import 'package:contacting_app/config/models/user_model.dart';
import 'package:contacting_app/features/profile/data/data_sources/remote/profile_remote_data_source_contract.dart';
import 'package:contacting_app/features/profile/domain/repos/profile_repo_contract.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: ProfileRepoContract)
class ProfileRepoImpl implements ProfileRepoContract{
  final ProfileRemoteDataSourceContract _dataSourceContract;
  ProfileRepoImpl(this._dataSourceContract);
  @override
  Future<BaseResponse<UserEntity>> getProfile() async{
    final response = await _dataSourceContract.getProfile();
    switch (response) {
      case SuccessResponse<UserModel>():
        return SuccessResponse<UserEntity>(data: response.data.toEntity());
      case ErrorResponse<UserModel>():
        return ErrorResponse<UserEntity>(error: response.error);
    }
  }

  @override
  Future<BaseResponse<void>> logout() async{
    return await _dataSourceContract.logout();
  }

  @override
  Future<BaseResponse<UserEntity>> updateProfile({required String name, String? photoUrl}) async{
    final response = await _dataSourceContract.updateProfile(
      name: name,
      photoUrl: photoUrl,
    );
    switch (response) {
      case SuccessResponse<UserModel>():
        return SuccessResponse<UserEntity>(data: response.data.toEntity());
      case ErrorResponse<UserModel>():
        return ErrorResponse<UserEntity>(error: response.error);
    }
  }

}