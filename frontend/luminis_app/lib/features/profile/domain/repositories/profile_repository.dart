import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> getCurrentProfile();

  Future<UserProfile> updateProfile(ProfileEditDraft draft);
}
