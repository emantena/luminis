class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.status,
    this.photoUrl,
    this.bio,
  });

  final String id;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final String status;

  @override
  bool operator ==(Object other) {
    return other is UserProfile &&
        other.id == id &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.bio == bio &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, displayName, photoUrl, bio, status);
}

class ProfileEditDraft {
  const ProfileEditDraft({
    required this.displayName,
    required this.photoUrl,
    required this.bio,
  });

  final String displayName;
  final String? photoUrl;
  final String? bio;
}

class ProfileStats {
  const ProfileStats({
    required this.booksRead,
    required this.currentlyReading,
    required this.pagesRead,
    required this.completedGoals,
  });

  final int booksRead;
  final int currentlyReading;
  final int pagesRead;
  final int completedGoals;
}
