import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/shared/infrastructure/api_error_mapper.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

void main() {
  group('ApiErrorMapper.fromResponse', () {
    test(
      'mapeia validation.failed para ApiValidationFailure com fieldErrors',
      () {
        final body = jsonEncode({
          'code': 'validation.failed',
          'message': 'Existem campos invalidos.',
          'traceId': '00-trace-span-01',
          'errors': {
            'email': ['Informe um email valido.'],
          },
        });

        final failure = ApiErrorMapper.fromResponse(
          statusCode: 400,
          body: body,
        );

        expect(failure, isA<ApiValidationFailure>());
        final validation = failure as ApiValidationFailure;
        expect(validation.code, 'validation.failed');
        expect(validation.message, 'Existem campos invalidos.');
        expect(validation.traceId, '00-trace-span-01');
        expect(validation.fieldErrors, {
          'email': ['Informe um email valido.'],
        });
      },
    );

    test('mapeia 401 auth.invalid_credentials para ApiUnauthorizedFailure', () {
      final body = jsonEncode({
        'code': 'auth.invalid_credentials',
        'message': 'Email ou senha invalidos.',
        'traceId': '00-abc-def-01',
        'errors': null,
      });

      final failure = ApiErrorMapper.fromResponse(statusCode: 401, body: body);

      expect(failure, isA<ApiUnauthorizedFailure>());
      expect(failure.code, 'auth.invalid_credentials');
      expect(failure.traceId, '00-abc-def-01');
    });

    test('mapeia 401 auth.account_locked para ApiUnauthorizedFailure', () {
      final body = jsonEncode({
        'code': 'auth.account_locked',
        'message': 'Conta temporariamente bloqueada.',
        'traceId': '00-locked-span-01',
        'errors': null,
      });

      final failure = ApiErrorMapper.fromResponse(statusCode: 401, body: body);

      expect(failure, isA<ApiUnauthorizedFailure>());
      expect(failure.code, 'auth.account_locked');
    });

    test('mapeia 409 para ApiConflictFailure', () {
      final body = jsonEncode({
        'code': 'auth.email_already_used',
        'message': 'Este email ja esta em uso.',
        'traceId': '00-conflict-span-01',
        'errors': null,
      });

      final failure = ApiErrorMapper.fromResponse(statusCode: 409, body: body);

      expect(failure, isA<ApiConflictFailure>());
    });

    test('mapeia 503 para ApiServiceUnavailableFailure', () {
      final body = jsonEncode({
        'code': 'catalog.provider_unavailable',
        'message': 'Servico indisponivel.',
        'traceId': '00-unavailable-span-01',
        'errors': null,
      });

      final failure = ApiErrorMapper.fromResponse(statusCode: 503, body: body);

      expect(failure, isA<ApiServiceUnavailableFailure>());
    });

    test('mapeia 404 para ApiNotFoundFailure', () {
      final body = jsonEncode({
        'code': 'catalog.book_not_found',
        'message': 'Obra nao encontrada.',
        'traceId': '00-notfound-span-01',
        'errors': null,
      });

      final failure = ApiErrorMapper.fromResponse(statusCode: 404, body: body);

      expect(failure, isA<ApiNotFoundFailure>());
    });

    test('usa fallback seguro quando o corpo esta vazio ou malformado', () {
      final failure = ApiErrorMapper.fromResponse(statusCode: 500, body: '');

      expect(failure, isA<ApiUnknownFailure>());
      expect(failure.code, 'unknown.error');
      expect(failure.message, isNotEmpty);
    });

    test('status nao mapeado explicitamente vira ApiUnknownFailure', () {
      final body = jsonEncode({
        'code': 'server.error',
        'message': 'Erro interno.',
        'traceId': '00-server-span-01',
        'errors': null,
      });

      final failure = ApiErrorMapper.fromResponse(statusCode: 500, body: body);

      expect(failure, isA<ApiUnknownFailure>());
    });
  });
}
