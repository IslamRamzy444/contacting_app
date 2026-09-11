import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/user_entity.dart';

abstract class LoginRepoContract {
  Future<BaseResponse<UserEntity>> login({
    required String email,
    required String password,
  });
}