import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/user_entity.dart';
import 'package:contacting_app/features/auth/login/domain/repos/login_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class LoginUseCase {
  final LoginRepoContract _repoContract;
  LoginUseCase(this._repoContract);
  Future<BaseResponse<UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return _repoContract.login(email: email, password: password);
  }
}