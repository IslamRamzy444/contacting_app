import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/config/models/call_model.dart';

abstract class CallsRemoteDataSourceContract {
  Future<BaseResponse<CallModel>> startCall({
    required String callerId,
    required String callerName,
    required String calleeId,
    required String calleeName,
    required CallType callType,
  });

  Future<BaseResponse<CallModel>> acceptCall(String callId);

  Future<BaseResponse<CallModel>> rejectCall(String callId);

  Future<BaseResponse<CallModel>> endCall({
    required String callId,
    int? duration,
  });

  BaseResponse<Stream<List<CallModel>>> getCallHistory(String userId);

  BaseResponse<Stream<CallModel?>> listenToIncomingCalls(String userId);

  /// Watches a single call document so both parties see status transitions
  /// (calling -> connected -> ended/rejected) in real time.
  BaseResponse<Stream<CallModel?>> listenToCallStatus(String callId);
}