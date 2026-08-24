import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:luminis_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:luminis_app/features/profile/domain/entities/user_profile.dart';
import 'package:luminis_app/shared/infrastructure/api_client.dart';

void main() {
  test('getCurrentProfile busca /me com bearer token', () async {
    final repository = ProfileRepositoryImpl(
      ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/me');
          expect(request.headers['Authorization'], 'Bearer token-abc');
          return http.Response(jsonEncode(_profileResponse), 200);
        }),
      ),
      bearerToken: 'token-abc',
    );

    final profile = await repository.getCurrentProfile();

    expect(profile.displayName, 'Ana Lima');
    expect(profile.bio, 'Leitora de fantasia.');
  });

  test('updateProfile envia displayName, photoUrl e bio', () async {
    final repository = ProfileRepositoryImpl(
      ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(request.url.path, '/api/me');
          expect(jsonDecode(request.body), {
            'displayName': 'Ana Leitora',
            'photoUrl': null,
            'bio': 'Bio atualizada',
          });
          return http.Response(
            jsonEncode({
              ..._profileResponse,
              'displayName': 'Ana Leitora',
              'bio': 'Bio atualizada',
            }),
            200,
          );
        }),
      ),
    );

    final profile = await repository.updateProfile(
      const ProfileEditDraft(
        displayName: 'Ana Leitora',
        photoUrl: null,
        bio: 'Bio atualizada',
      ),
    );

    expect(profile.displayName, 'Ana Leitora');
    expect(profile.bio, 'Bio atualizada');
  });
}

const _profileResponse = <String, Object?>{
  'id': 'usr_ana_lima',
  'displayName': 'Ana Lima',
  'photoUrl': null,
  'bio': 'Leitora de fantasia.',
  'status': 'active',
};
