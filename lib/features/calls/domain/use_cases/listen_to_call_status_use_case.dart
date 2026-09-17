import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/features/calls/domain/repos/calls_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class ListenToCallStatusUseCase {
  final CallsRepoContract _repoContract;
  ListenToCallStatusUseCase(this._repoContract);

  BaseResponse<Stream<CallEntity?>> call(String callId) {
    return _repoContract.listenToCallStatus(callId);
  }
}
