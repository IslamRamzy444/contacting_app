import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/models/user_model.dart';

abstract class LoginRemoteDataSourceContract {
  Future<BaseResponse<UserModel>> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
}