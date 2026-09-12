import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/user_entity.dart';

abstract class ProfileRepoContract {
  Future<BaseResponse<UserEntity>> getProfile();
  Future<BaseResponse<UserEntity>> updateProfile({
    required String name,
    String? photoUrl,
  });
  Future<BaseResponse<void>> logout();
}