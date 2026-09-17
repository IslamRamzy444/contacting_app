import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/features/calls/domain/repos/calls_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class EndCallUseCase {
  final CallsRepoContract _repoContract;
  EndCallUseCase(this._repoContract);
  Future<BaseResponse<CallEntity>> call({
    required String callId,
    int? duration,
  }) async {
    return _repoContract.endCall(callId: callId, duration: duration);
  }
}