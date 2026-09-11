import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/features/splash/domain/repos/auth_status_repo_contract.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: AuthStatusRepoContract)
class AuthStatusRepoImpl implements AuthStatusRepoContract{
  final FirebaseAuth _auth;
  AuthStatusRepoImpl(this._auth);
  @override
  Future<BaseResponse<bool>> isUserLoggedIn() async{
    try {
      final user = _auth.currentUser;
      return SuccessResponse<bool>(data: user != null);
    } catch (e) {
      return ErrorResponse<bool>(error: Exception(e.toString()));
    }
  }

}