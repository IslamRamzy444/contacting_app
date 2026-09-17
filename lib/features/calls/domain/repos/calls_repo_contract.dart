import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/call_entity.dart';

abstract class CallsRepoContract {
  Future<BaseResponse<CallEntity>> startCall({
    required String callerId,
    required String callerName,
    required String calleeId,
    required String calleeName,
    required CallType callType,
  });

  Future<BaseResponse<CallEntity>> acceptCall(String callId);

  Future<BaseResponse<CallEntity>> rejectCall(String callId);

  Future<BaseResponse<CallEntity>> endCall({
    required String callId,
    int? duration,
  });

  BaseResponse<Stream<List<CallEntity>>> getCallHistory(String userId);

  BaseResponse<Stream<CallEntity?>> listenToIncomingCalls(String userId);

  BaseResponse<Stream<CallEntity?>> listenToCallStatus(String callId);
}