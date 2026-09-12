import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/user_entity.dart';
import 'package:contacting_app/features/profile/domain/repos/profile_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class GetProfileUseCase {
  final ProfileRepoContract _repoContract;
  GetProfileUseCase(this._repoContract);
  Future<BaseResponse<UserEntity>> call()async{
    return _repoContract.getProfile();
  }
}