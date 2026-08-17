/// Usuário interno do Luminis (módulo Identity), conforme
/// `docs/architecture/backend-contracts.md`.
///
/// Representa tanto o usuário resumido devolvido por
/// `/api/auth/login|register|google` quanto o usuário completo de
/// `GET /api/me` — `bio` é `null` quando a origem não o preenche.
class User {
  const User({
    required this.id,
    required this.displayName,
    required this.status,
    this.photoUrl,
    this.bio,
  });

  /// Identificador opaco do usuário.
  final String id;

  final String displayName;

  /// `null` quando o usuário não tem foto definida.
  final String? photoUrl;

  /// `null` quando o usuário não tem bio definida ou quando a origem da
  /// resposta (ex.: login) não inclui este campo.
  final String? bio;

  /// Valor bruto de `users.status` (`active`, `suspended`, `deleted`),
  /// conforme `docs/data/database-schema-mvp.md`. Mantido como texto porque
  /// esta feature não decide regra de bloqueio por status — isso pertence a
  /// `application`/backend quando necessário.
  final String status;

  User copyWith({String? displayName, String? photoUrl, String? bio}) {
    return User(
      id: id,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      status: status,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is User &&
        other.id == id &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.bio == bio &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, displayName, photoUrl, bio, status);

  @override
  String toString() => 'User(id: $id, displayName: $displayName)';
}
