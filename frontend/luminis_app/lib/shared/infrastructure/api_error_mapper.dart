import 'dart:convert';

import 'api_exception.dart';

/// Converte uma resposta HTTP de erro no envelope padrão do Luminis
/// (`code`, `message`, `traceId`, `errors` — ver
/// `docs/architecture/backend-contracts.md`) para um [ApiResponseFailure]
/// tipado. Não decide texto de UI; apenas preserva o que o backend já
/// considerou seguro para expor.
abstract final class ApiErrorMapper {
  static const String _validationCode = 'validation.failed';
  static const String _fallbackCode = 'unknown.error';
  static const String _fallbackMessage =
      'Ocorreu um erro inesperado. Tente novamente.';

  static ApiResponseFailure fromResponse({
    required int statusCode,
    required String body,
  }) {
    final Map<String, dynamic>? envelope = _decodeEnvelope(body);

    final String code = _readString(envelope, 'code') ?? _fallbackCode;
    final String message = _readString(envelope, 'message') ?? _fallbackMessage;
    final String? traceId = _readString(envelope, 'traceId');

    if (code == _validationCode) {
      return ApiValidationFailure(
        code: code,
        message: message,
        statusCode: statusCode,
        traceId: traceId,
        fieldErrors: _decodeFieldErrors(envelope?['errors']),
      );
    }

    switch (statusCode) {
      case 401:
        return ApiUnauthorizedFailure(
          code: code,
          message: message,
          statusCode: statusCode,
          traceId: traceId,
        );
      case 404:
        return ApiNotFoundFailure(
          code: code,
          message: message,
          statusCode: statusCode,
          traceId: traceId,
        );
      case 409:
        return ApiConflictFailure(
          code: code,
          message: message,
          statusCode: statusCode,
          traceId: traceId,
        );
      case 503:
        return ApiServiceUnavailableFailure(
          code: code,
          message: message,
          statusCode: statusCode,
          traceId: traceId,
        );
      default:
        return ApiUnknownFailure(
          code: code,
          message: message,
          statusCode: statusCode,
          traceId: traceId,
        );
    }
  }

  static Map<String, dynamic>? _decodeEnvelope(String body) {
    if (body.isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  static String? _readString(Map<String, dynamic>? envelope, String key) {
    final Object? value = envelope?[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  static Map<String, List<String>> _decodeFieldErrors(Object? rawErrors) {
    if (rawErrors is! Map) {
      return const {};
    }
    final Map<String, List<String>> result = {};
    for (final MapEntry<Object?, Object?> entry in rawErrors.entries) {
      final String field = entry.key.toString();
      final Object? value = entry.value;
      if (value is List) {
        result[field] = value.map((Object? item) => item.toString()).toList();
      } else if (value != null) {
        result[field] = [value.toString()];
      }
    }
    return result;
  }
}
