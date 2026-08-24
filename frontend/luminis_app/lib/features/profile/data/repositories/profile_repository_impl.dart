import '../../../../shared/infrastructure/api_client.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../mappers/profile_mapper.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._apiClient, {this.bearerToken});

  final ApiClient _apiClient;
  final String? bearerToken;

  @override
  Future<UserProfile> getCurrentProfile() async {
    final response = await _apiClient.get('/me', bearerToken: bearerToken);
    return ProfileMapper.profileFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserProfile> updateProfile(ProfileEditDraft draft) async {
    final response = await _apiClient.patch(
      '/me',
      bearerToken: bearerToken,
      body: {
        'displayName': draft.displayName,
        'photoUrl': draft.photoUrl,
        'bio': draft.bio,
      },
    );
    return ProfileMapper.profileFromJson(response as Map<String, dynamic>);
  }
}
