import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/models/user_model.dart';

abstract class RegisterRemoteDataSourceContract {
  Future<BaseResponse<UserModel>> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });
}