import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/models/contact_model.dart';
import 'package:contacting_app/features/search/data/data_sources/remote/search_remote_data_source_contract.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: SearchRemoteDataSourceContract)
class SearchRemoteDataSourceImpl implements SearchRemoteDataSourceContract{
  final FirebaseFirestore _firestore;
  SearchRemoteDataSourceImpl(this._firestore);
  @override
  Future<BaseResponse<List<ContactModel>>> searchUsers({required String query, required String currentUserId}) async{
    try{
      final snapshot = await _firestore.collection('users').get();
      final allUsers = snapshot.docs.map((doc) => ContactModel.fromJson(doc.data())).where((u) => u.id != currentUserId).toList();
      final trimmed = query.trim().toLowerCase();
      final result = trimmed.isEmpty? allUsers: allUsers.where((u) => u.name.toLowerCase().contains(trimmed)).toList();
      return SuccessResponse<List<ContactModel>>(data: result);
    }on FirebaseException catch(e){
      return ErrorResponse<List<ContactModel>>(error: Exception(e.message ?? 'Firestore error'),);
    }catch(e){
      return ErrorResponse<List<ContactModel>>(error: Exception(e.toString()));
    }
  }

}