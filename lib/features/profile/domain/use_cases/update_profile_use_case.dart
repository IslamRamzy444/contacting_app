import 'package:contacting_app/config/base_response/base_response.dart';
import 'package:contacting_app/config/entities/user_entity.dart';
import 'package:contacting_app/features/profile/domain/repos/profile_repo_contract.dart';
import 'package:injectable/injectable.dart';
@injectable
class UpdateProfileUseCase {
  final ProfileRepoContract _repoContract;
  UpdateProfileUseCase(this._repoContract);
  Future<BaseResponse<UserEntity>> call({
    required String name,
    String? photoUrl,
  }) async {
    return _repoContract.updateProfile(
      name: name,
      photoUrl: photoUrl,
    );
  }
}