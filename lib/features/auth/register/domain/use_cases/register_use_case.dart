import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/user_entity.dart';
import 'package:contacting_app/features/auth/register/domain/repos/register_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class RegisterUseCase {
  final RegisterRepoContract _repoContract;
  RegisterUseCase(this._repoContract);
  Future<BaseResponse<UserEntity>> call({
    required String name,
    required String email,
    required String password,
  }) async {
    return _repoContract.register(
      name: name,
      email: email,
      password: password,
    );
  }
}