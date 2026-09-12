import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/features/profile/domain/repos/profile_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class LogoutUseCase {
  final ProfileRepoContract _repoContract;
  LogoutUseCase(this._repoContract);
  Future<BaseResponse<void>> call() async {
    return _repoContract.logout();
  }
}