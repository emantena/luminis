import '../../domain/entities/user_profile.dart';

abstract final class ProfileMapper {
  static UserProfile profileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      status: json['status'] as String,
    );
  }
}
