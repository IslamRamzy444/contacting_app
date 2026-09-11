import 'package:contacting_app/config/base_response/base_response.dart';

abstract class AuthStatusRepoContract {
  Future<BaseResponse<bool>> isUserLoggedIn();
}