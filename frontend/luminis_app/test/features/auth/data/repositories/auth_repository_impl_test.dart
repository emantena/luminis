import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:luminis_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:luminis_app/shared/infrastructure/api_client.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('login mapeia a resposta de /auth/login para Session', () async {
      final repository = AuthRepositoryImpl(
        ApiClient(
          baseUrl: 'http://mock.local/api',
          httpClient: MockClient((request) async {
            expect(request.url.path, '/api/auth/login');
            expect(jsonDecode(request.body), {
              'email': 'ana@email.com',
              'password': 'senha-forte',
            });
            return http.Response(
              jsonEncode({
                'accessToken': 'jwt-abc',
                'refreshToken': 'refresh-abc',
                'expiresAt': '2026-08-06T18:00:00Z',
                'user': {
                  'id': 'usr_1',
                  'displayName': 'Ana Leitora',
                  'photoUrl': null,
                  'status': 'active',
                },
              }),
              200,
            );
          }),
        ),
      );

      final session = await repository.login(
        email: 'ana@email.com',
        password: 'senha-forte',
      );

      expect(session.accessToken, 'jwt-abc');
      expect(session.refreshToken, 'refresh-abc');
      expect(session.expiresAt, DateTime.parse('2026-08-06T18:00:00Z'));
      expect(session.user.id, 'usr_1');
      expect(session.user.displayName, 'Ana Leitora');
      expect(session.user.photoUrl, isNull);
      expect(session.user.bio, isNull);
      expect(session.user.status, 'active');
    });

    test(
      'login propaga ApiUnauthorizedFailure em credenciais inválidas',
      () async {
        final repository = AuthRepositoryImpl(
          ApiClient(
            baseUrl: 'http://mock.local/api',
            httpClient: MockClient((request) async {
              return http.Response(
                jsonEncode({
                  'code': 'auth.invalid_credentials',
                  'message': 'Email ou senha invalidos.',
                }),
                401,
              );
            }),
          ),
        );

        await expectLater(
          repository.login(email: 'ana@email.com', password: 'errada'),
          throwsA(isA<ApiUnauthorizedFailure>()),
        );
      },
    );

    test('register propaga ApiConflictFailure em email duplicado', () async {
      final repository = AuthRepositoryImpl(
        ApiClient(
          baseUrl: 'http://mock.local/api',
          httpClient: MockClient((request) async {
            expect(request.url.path, '/api/auth/register');
            return http.Response(
              jsonEncode({
                'code': 'auth.email_already_used',
                'message': 'Este email ja esta em uso.',
              }),
              409,
            );
          }),
        ),
      );

      await expectLater(
        repository.register(
          displayName: 'Ana Leitora',
          email: 'ana@email.com',
          password: 'senha-forte',
        ),
        throwsA(isA<ApiConflictFailure>()),
      );
    });

    test('getCurrentUser mapeia a resposta de /me com bio', () async {
      final repository = AuthRepositoryImpl(
        ApiClient(
          baseUrl: 'http://mock.local/api',
          httpClient: MockClient((request) async {
            expect(request.url.path, '/api/me');
            expect(request.headers['Authorization'], 'Bearer jwt-abc');
            return http.Response(
              jsonEncode({
                'id': 'usr_1',
                'displayName': 'Ana Leitora',
                'photoUrl': null,
                'bio': 'Leio ficção científica.',
                'status': 'active',
              }),
              200,
            );
          }),
        ),
      );

      final user = await repository.getCurrentUser(accessToken: 'jwt-abc');

      expect(user.bio, 'Leio ficção científica.');
    });

    test('logout envia refreshToken e bearer token', () async {
      final repository = AuthRepositoryImpl(
        ApiClient(
          baseUrl: 'http://mock.local/api',
          httpClient: MockClient((request) async {
            expect(request.url.path, '/api/auth/logout');
            expect(request.headers['Authorization'], 'Bearer jwt-abc');
            expect(jsonDecode(request.body), {'refreshToken': 'refresh-abc'});
            return http.Response(jsonEncode({'success': true}), 200);
          }),
        ),
      );

      await repository.logout(
        accessToken: 'jwt-abc',
        refreshToken: 'refresh-abc',
      );
    });
  });
}
