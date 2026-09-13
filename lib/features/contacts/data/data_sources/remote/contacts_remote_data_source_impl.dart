import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/models/contact_model.dart';
import 'package:contacting_app/features/contacts/data/data_sources/remote/contacts_remote_data_source_contract.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: ContactsRemoteDataSourceContract)
class ContactsRemoteDataSourceImpl implements ContactsRemoteDataSourceContract{
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  ContactsRemoteDataSourceImpl(this._firestore, this._auth);

  @override
  BaseResponse<Stream<List<ContactModel>>> getContacts() {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        return ErrorResponse<Stream<List<ContactModel>>>(
          error: Exception('User not authenticated'),
        );
      }
      final stream = _firestore
          .collection('users')
          .where('uid', isNotEqualTo: currentUserId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return ContactModel.fromJson(doc.data());
            }).toList();
          });

      return SuccessResponse<Stream<List<ContactModel>>>(data: stream);
    } catch (e) {
      return ErrorResponse<Stream<List<ContactModel>>>(
        error: Exception(e.toString()),
      );
    }
  }
}