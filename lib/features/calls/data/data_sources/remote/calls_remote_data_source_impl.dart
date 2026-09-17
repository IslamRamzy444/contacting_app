import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/config/models/call_model.dart';
import 'package:contacting_app/features/calls/data/data_sources/remote/calls_remote_data_source_contract.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: CallsRemoteDataSourceContract)
class CallsRemoteDataSourceImpl implements CallsRemoteDataSourceContract {
  final FirebaseFirestore _firestore;
  CallsRemoteDataSourceImpl(this._firestore);
  static const _collection = 'calls';
  @override
  Future<BaseResponse<CallModel>> acceptCall(String callId) async {
    try {
      final ref = _firestore.collection(_collection).doc(callId);

      // Accepting must be conditional on the call still ringing. A blind
      // update would resurrect a call the caller already cancelled, producing
      // a screen that says "connected" with nobody on the other end.
      final accepted = await _firestore.runTransaction<CallModel>((tx) async {
        final snapshot = await tx.get(ref);
        if (!snapshot.exists || snapshot.data() == null) {
          throw StateError('call-not-found');
        }

        final current = CallModel.fromJson(snapshot.data()!);
        if (current.status != CallStatus.calling) {
          throw StateError('call-no-longer-ringing:${current.status.name}');
        }

        tx.update(ref, {
          'status': CallStatus.connected.name,
          'connectedAt': FieldValue.serverTimestamp(),
        });

        return current.copyWith(status: CallStatus.connected);
      });

      return SuccessResponse<CallModel>(data: accepted);
    } catch (e) {
      return ErrorResponse<CallModel>(error: Exception(e.toString()));
    }
  }

  @override
  Future<BaseResponse<CallModel>> endCall({
    required String callId,
    int? duration,
  }) async {
    try {
      final doc = await _firestore.collection(_collection).doc(callId).get();
      final current = CallModel.fromJson(doc.data()!);

      final finalStatus = current.status == CallStatus.connected
          ? CallStatus.ended
          : CallStatus.missed;

      await _firestore.collection(_collection).doc(callId).update({
        'status': finalStatus.name,
        'endedAt': FieldValue.serverTimestamp(),
        // ignore: use_null_aware_elements
        if (duration != null) 'duration': duration,
      });

      final updatedDoc = await _firestore
          .collection(_collection)
          .doc(callId)
          .get();
      return SuccessResponse<CallModel>(
        data: CallModel.fromJson(updatedDoc.data()!),
      );
    } catch (e) {
      return ErrorResponse<CallModel>(error: Exception(e.toString()));
    }
  }

  @override
  BaseResponse<Stream<List<CallModel>>> getCallHistory(String userId) {
    try {
      final callerStream = _firestore
          .collection(_collection)
          .where('callerId', isEqualTo: userId)
          .snapshots();

      final calleeStream = _firestore
          .collection(_collection)
          .where('calleeId', isEqualTo: userId)
          .snapshots();

      final combinedStream = _mergeCallStreams(callerStream, calleeStream);

      return SuccessResponse<Stream<List<CallModel>>>(data: combinedStream);
    } catch (e) {
      return ErrorResponse<Stream<List<CallModel>>>(
        error: Exception(e.toString()),
      );
    }
  }

  Stream<List<CallModel>> _mergeCallStreams(
    Stream<QuerySnapshot<Map<String, dynamic>>> callerStream,
    Stream<QuerySnapshot<Map<String, dynamic>>> calleeStream,
  ) {
    final controller = StreamController<List<CallModel>>();

    List<CallModel> callerCalls = [];
    List<CallModel> calleeCalls = [];

    void emitCombined() {
      final Map<String, CallModel> merged = {};

      for (final call in callerCalls) {
        merged[call.id!] = call;
      }
      for (final call in calleeCalls) {
        merged[call.id!] = call;
      }

      
      final sorted = merged.values.toList()
        ..sort((a, b) {
          final aTime = a.startedAt ?? DateTime(0);
          final bTime = b.startedAt ?? DateTime(0);
          return bTime.compareTo(aTime);
        });

      if (!controller.isClosed) {
        controller.add(sorted);
      }
    }

    final callerSub = callerStream.listen((snapshot) {
      callerCalls = snapshot.docs
          .map((doc) => CallModel.fromJson(doc.data()))
          .toList();
      emitCombined();
    });

    final calleeSub = calleeStream.listen((snapshot) {
      calleeCalls = snapshot.docs
          .map((doc) => CallModel.fromJson(doc.data()))
          .toList();
      emitCombined();
    });

    controller.onCancel = () {
      callerSub.cancel();
      calleeSub.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  BaseResponse<Stream<CallModel?>> listenToIncomingCalls(String userId) {
    try {
      final stream = _firestore
          .collection(_collection)
          .where('calleeId', isEqualTo: userId)
          .where('status', isEqualTo: CallStatus.calling.name)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) return null;
            return CallModel.fromJson(snapshot.docs.first.data());
          });
      return SuccessResponse<Stream<CallModel?>>(data: stream);
    } catch (e) {
      return ErrorResponse<Stream<CallModel?>>(error: Exception(e.toString()));
    }
  }

  @override
  BaseResponse<Stream<CallModel?>> listenToCallStatus(String callId) {
    try {
      final stream = _firestore
          .collection(_collection)
          .doc(callId)
          .snapshots()
          .map((doc) {
            if (!doc.exists || doc.data() == null) return null;
            return CallModel.fromJson(doc.data()!);
          });
      return SuccessResponse<Stream<CallModel?>>(data: stream);
    } catch (e) {
      return ErrorResponse<Stream<CallModel?>>(error: Exception(e.toString()));
    }
  }

  @override
  Future<BaseResponse<CallModel>> rejectCall(String callId) async {
    try {
      final ref = _firestore.collection(_collection).doc(callId);

      // Same guard as accept: don't overwrite a call the caller already
      // cancelled, or a missed call would be relabelled as rejected.
      final rejected = await _firestore.runTransaction<CallModel>((tx) async {
        final snapshot = await tx.get(ref);
        if (!snapshot.exists || snapshot.data() == null) {
          throw StateError('call-not-found');
        }

        final current = CallModel.fromJson(snapshot.data()!);
        if (current.status != CallStatus.calling) return current;

        tx.update(ref, {
          'status': CallStatus.rejected.name,
          'endedAt': FieldValue.serverTimestamp(),
        });
        return current.copyWith(status: CallStatus.rejected);
      });

      return SuccessResponse<CallModel>(data: rejected);
    } catch (e) {
      return ErrorResponse<CallModel>(error: Exception(e.toString()));
    }
  }

  @override
  Future<BaseResponse<CallModel>> startCall({
    required String callerId,
    required String callerName,
    required String calleeId,
    required String calleeName,
    required CallType callType,
  }) async {
    try {
      await _cleanupStaleCalls(callerId);
      await _cleanupStaleCalls(calleeId);

      final channelName = const Uuid().v4().replaceAll('-', '');
      final docRef = _firestore.collection(_collection).doc();

      final model = CallModel(
        id: docRef.id,
        callerId: callerId,
        callerName: callerName,
        calleeId: calleeId,
        calleeName: calleeName,
        channelName: channelName,
        callType: callType,
        status: CallStatus.calling,
      );

      final data = model.toJson();
      data['startedAt'] = FieldValue.serverTimestamp();

      await docRef.set(data);

      return SuccessResponse<CallModel>(data: model);
    } catch (e) {
      return ErrorResponse<CallModel>(error: Exception(e.toString()));
    }
  }

  Future<void> _cleanupStaleCalls(String userId) async {
    try {
      final asCaller = await _firestore
          .collection(_collection)
          .where('callerId', isEqualTo: userId)
          .where('status', isEqualTo: CallStatus.calling.name)
          .get();

      for (final doc in asCaller.docs) {
        await doc.reference.update({
          'status': CallStatus.missed.name,
          'endedAt': FieldValue.serverTimestamp(),
        });
      }

      final asCallee = await _firestore
          .collection(_collection)
          .where('calleeId', isEqualTo: userId)
          .where('status', isEqualTo: CallStatus.calling.name)
          .get();

      for (final doc in asCallee.docs) {
        await doc.reference.update({
          'status': CallStatus.missed.name,
          'endedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Non-fatal — ignore
    }
  }
}
