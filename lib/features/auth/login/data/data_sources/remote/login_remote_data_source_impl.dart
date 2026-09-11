import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/models/user_model.dart';
import 'package:contacting_app/features/auth/login/data/data_sources/remote/login_remote_data_source_contract.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: LoginRemoteDataSourceContract)
class LoginRemoteDataSourceImpl implements LoginRemoteDataSourceContract{
  final FirebaseAuth _auth;
  LoginRemoteDataSourceImpl(this._auth);
  @override
  Future<BaseResponse<UserModel>> loginWithEmailAndPassword({required String email, required String password}) async{
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      final model = UserModel.fromFirebaseUser(user);
      return SuccessResponse<UserModel>(data: model);
    } on FirebaseAuthException catch (e) {
      return ErrorResponse<UserModel>(error: Exception(e.message));
    } catch (e) {
      return ErrorResponse<UserModel>(error: Exception(e.toString()));
    }
  }
}