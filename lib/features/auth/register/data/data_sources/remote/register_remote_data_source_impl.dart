import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/models/user_model.dart';
import 'package:contacting_app/features/auth/register/data/data_sources/remote/register_remote_data_source_contract.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: RegisterRemoteDataSourceContract)
class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSourceContract{
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  RegisterRemoteDataSourceImpl(this._auth,this._firestore);
  @override
  Future<BaseResponse<UserModel>> registerWithEmailAndPassword({required String name, required String email, required String password}) async{
    try{
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();

      final user = _auth.currentUser!;
      final model=UserModel.fromFirebaseUser(user);
      await _firestore.collection('users').doc(user.uid).set({
        ...model.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return SuccessResponse<UserModel>(data: model);
    }on FirebaseAuthException catch(e){
      return ErrorResponse<UserModel>(error: Exception(e.message));
    }catch(e){
      return ErrorResponse<UserModel>(error: Exception(e.toString()));
    }
  }
}