import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:luminis_app/shared/infrastructure/api_client.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

void main() {
  group('ApiClient', () {
    test('get decodifica JSON de sucesso', () async {
      final client = ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), 'http://mock.local/api/me');
          expect(request.headers['Accept'], 'application/json');
          return http.Response(
            jsonEncode({'id': 'usr_1', 'displayName': 'Ana'}),
            200,
          );
        }),
      );

      final result = await client.get('/me');

      expect(result, {'id': 'usr_1', 'displayName': 'Ana'});
    });

    test(
      'post envia corpo JSON e Authorization quando bearerToken informado',
      () async {
        final client = ApiClient(
          baseUrl: 'http://mock.local/api',
          httpClient: MockClient((request) async {
            expect(request.method, 'POST');
            expect(request.headers['Authorization'], 'Bearer token-123');
            expect(jsonDecode(request.body), {'refreshToken': 'refresh-abc'});
            return http.Response('{"success":true}', 200);
          }),
        );

        final result = await client.post(
          '/auth/logout',
          body: {'refreshToken': 'refresh-abc'},
          bearerToken: 'token-123',
        );

        expect(result, {'success': true});
      },
    );

    test('resposta 204 sem corpo retorna null', () async {
      final client = ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          return http.Response('', 204);
        }),
      );

      final result = await client.delete('/bookshelf-items/1');

      expect(result, isNull);
    });

    test('resposta de erro lanca ApiFailure tipado', () async {
      final client = ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'code': 'auth.invalid_credentials',
              'message': 'Email ou senha invalidos.',
              'traceId': '00-trace-span-01',
              'errors': null,
            }),
            401,
          );
        }),
      );

      await expectLater(
        client.post('/auth/login', body: {'email': 'a@b.com', 'password': 'x'}),
        throwsA(isA<ApiUnauthorizedFailure>()),
      );
    });

    test('falha de conexao lanca ApiNetworkFailure', () async {
      final client = ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          throw http.ClientException('conexao recusada');
        }),
      );

      await expectLater(client.get('/me'), throwsA(isA<ApiNetworkFailure>()));
    });
  });
}
