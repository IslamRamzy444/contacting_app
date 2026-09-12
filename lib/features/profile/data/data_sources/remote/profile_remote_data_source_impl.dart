import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/models/user_model.dart';
import 'package:contacting_app/features/profile/data/data_sources/remote/profile_remote_data_source_contract.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: ProfileRemoteDataSourceContract)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSourceContract{
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  ProfileRemoteDataSourceImpl(this._auth,this._firestore);
  @override
  Future<BaseResponse<UserModel>> getProfile() async{
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return ErrorResponse<UserModel>(
          error: Exception('User not authenticated'),
        );
      }
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      if (data == null) {
        final user = _auth.currentUser!;
        return SuccessResponse<UserModel>(
          data: UserModel.fromFirebaseUser(user),
        );
      }
      return SuccessResponse<UserModel>(data: UserModel.fromJson(data));
    } catch (e) {
      return ErrorResponse<UserModel>(error: Exception(e.toString()));
    }
  }

  @override
  Future<BaseResponse<void>> logout() async{
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'isOnline': false,
        });
      }
      await _auth.signOut();
      return SuccessResponse<void>(data: null);
    } catch (e) {
      return ErrorResponse<void>(error: Exception(e.toString()));
    }
  }

  @override
  Future<BaseResponse<UserModel>> updateProfile({required String name, String? photoUrl}) async{
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return ErrorResponse<UserModel>(
          error: Exception('User not authenticated'),
        );
      }
      final updateData = <String, dynamic>{'name': name};
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }
      await _firestore.collection('users').doc(userId).update(updateData);
      await _auth.currentUser?.updateDisplayName(name);
      final doc = await _firestore.collection('users').doc(userId).get();
      return SuccessResponse<UserModel>(
        data: UserModel.fromJson(doc.data()!),
      );
    } catch (e) {
      return ErrorResponse<UserModel>(error: Exception(e.toString()));
    }
  }
}