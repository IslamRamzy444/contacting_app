import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/models/user_model.dart';

abstract class ProfileRemoteDataSourceContract {
  Future<BaseResponse<UserModel>> getProfile();
  Future<BaseResponse<UserModel>> updateProfile({
    required String name,
    String? photoUrl,
  });
  Future<BaseResponse<void>> logout();
}