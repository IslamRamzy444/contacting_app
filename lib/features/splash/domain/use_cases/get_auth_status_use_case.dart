import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/features/splash/domain/repos/auth_status_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class GetAuthStatusUseCase {
  final AuthStatusRepoContract _repoContract;
  GetAuthStatusUseCase(this._repoContract);
  Future<BaseResponse<bool>> call()async{
    return _repoContract.isUserLoggedIn();
  }
}