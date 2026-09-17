import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/config/models/call_model.dart';
import 'package:contacting_app/features/calls/data/data_sources/remote/calls_remote_data_source_contract.dart';
import 'package:contacting_app/features/calls/domain/repos/calls_repo_contract.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: CallsRepoContract)
class CallsRepoImpl implements CallsRepoContract {
  final CallsRemoteDataSourceContract _dataSourceContract;
  CallsRepoImpl(this._dataSourceContract);
  @override
  Future<BaseResponse<CallEntity>> acceptCall(String callId) async {
    final response = await _dataSourceContract.acceptCall(callId);
    switch (response) {
      case SuccessResponse<CallModel>():
        return SuccessResponse<CallEntity>(data: response.data.toEntity());
      case ErrorResponse<CallModel>():
        return ErrorResponse<CallEntity>(error: response.error);
    }
  }

  @override
  Future<BaseResponse<CallEntity>> endCall({
    required String callId,
    int? duration,
  }) async {
    final response = await _dataSourceContract.endCall(
      callId: callId,
      duration: duration,
    );
    switch (response) {
      case SuccessResponse<CallModel>():
        return SuccessResponse<CallEntity>(data: response.data.toEntity());
      case ErrorResponse<CallModel>():
        return ErrorResponse<CallEntity>(error: response.error);
    }
  }

  @override
  BaseResponse<Stream<List<CallEntity>>> getCallHistory(String userId) {
    final response = _dataSourceContract.getCallHistory(userId);

    switch (response) {
      case SuccessResponse<Stream<List<CallModel>>>():
        final entityStream = response.data.map((models) {
          return models.map((model) => model.toEntity()).toList();
        });
        return SuccessResponse<Stream<List<CallEntity>>>(data: entityStream);

      case ErrorResponse<Stream<List<CallModel>>>():
        return ErrorResponse<Stream<List<CallEntity>>>(error: response.error);
    }
  }

  @override
  BaseResponse<Stream<CallEntity?>> listenToIncomingCalls(String userId) {
    final response = _dataSourceContract.listenToIncomingCalls(userId);
    switch (response) {
      case SuccessResponse<Stream<CallModel?>>():
        final entityStream = response.data.map((model) => model?.toEntity());
        return SuccessResponse<Stream<CallEntity?>>(data: entityStream);
      case ErrorResponse<Stream<CallModel?>>():
        return ErrorResponse<Stream<CallEntity?>>(error: response.error);
    }
  }

  @override
  BaseResponse<Stream<CallEntity?>> listenToCallStatus(String callId) {
    final response = _dataSourceContract.listenToCallStatus(callId);
    switch (response) {
      case SuccessResponse<Stream<CallModel?>>():
        final entityStream = response.data.map((model) => model?.toEntity());
        return SuccessResponse<Stream<CallEntity?>>(data: entityStream);
      case ErrorResponse<Stream<CallModel?>>():
        return ErrorResponse<Stream<CallEntity?>>(error: response.error);
    }
  }

  @override
  Future<BaseResponse<CallEntity>> rejectCall(String callId) async {
    final response = await _dataSourceContract.rejectCall(callId);
    switch (response) {
      case SuccessResponse<CallModel>():
        return SuccessResponse<CallEntity>(data: response.data.toEntity());
      case ErrorResponse<CallModel>():
        return ErrorResponse<CallEntity>(error: response.error);
    }
  }

  @override
  Future<BaseResponse<CallEntity>> startCall({
    required String callerId,
    required String callerName,
    required String calleeId,
    required String calleeName,
    required CallType callType,
  }) async {
    final response = await _dataSourceContract.startCall(
      callerId: callerId,
      callerName: callerName,
      calleeId: calleeId,
      calleeName: calleeName,
      callType: callType,
    );

    switch (response) {
      case SuccessResponse<CallModel>():
        return SuccessResponse<CallEntity>(data: response.data.toEntity());
      case ErrorResponse<CallModel>():
        return ErrorResponse<CallEntity>(error: response.error);
    }
  }
}
