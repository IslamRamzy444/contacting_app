import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/features/calls/domain/repos/calls_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class StartCallUseCase {
  final CallsRepoContract _repoContract;
  StartCallUseCase(this._repoContract);
  Future<BaseResponse<CallEntity>> call({
    required String callerId,
    required String callerName,
    required String calleeId,
    required String calleeName,
    required CallType callType,
  }) async {
    return _repoContract.startCall(
      callerId: callerId,
      callerName: callerName,
      calleeId: calleeId,
      calleeName: calleeName,
      callType: callType,
    );
  }
}