import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/features/calls/domain/repos/calls_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class RejectCallUseCase {
  final CallsRepoContract _repoContract;
  RejectCallUseCase(this._repoContract);
  Future<BaseResponse<CallEntity>> call(String callId) async {
    return _repoContract.rejectCall(callId);
  }
}