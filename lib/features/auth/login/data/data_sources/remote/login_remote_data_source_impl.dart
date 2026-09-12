import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/models/user_model.dart';
import 'package:contacting_app/features/auth/login/data/data_sources/remote/login_remote_data_source_contract.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: LoginRemoteDataSourceContract)
class LoginRemoteDataSourceImpl implements LoginRemoteDataSourceContract{
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  LoginRemoteDataSourceImpl(this._auth,this._firestore);
  @override
  Future<BaseResponse<UserModel>> loginWithEmailAndPassword({required String email, required String password}) async{
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': true,
      });
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final model = UserModel.fromJson(doc.data()!);
      return SuccessResponse<UserModel>(data: model);
    } on FirebaseAuthException catch (e) {
      return ErrorResponse<UserModel>(error: Exception(e.message));
    } catch (e) {
      return ErrorResponse<UserModel>(error: Exception(e.toString()));
    }
  }
}