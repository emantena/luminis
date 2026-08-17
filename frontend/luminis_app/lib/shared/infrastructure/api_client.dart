import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_error_mapper.dart';
import 'api_exception.dart';

/// Cliente HTTP compartilhado para consumir a fronteira HTTP do Luminis
/// (`backend/mock-api/` hoje; API .NET real depois — ADR-009, ADR-010).
///
/// Apenas repositories em `data/` devem instanciar/usar [ApiClient].
/// Nenhuma feature ou widget deve referenciar `package:http` diretamente.
///
/// Centraliza base URL, timeout, headers padrão e decodificação/erro de
/// JSON para evitar duplicação entre repositories, conforme ADR-010.
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
    : _httpClient = httpClient ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _httpClient;
  final String _baseUrl;

  /// Executa `GET <baseUrl><path>`.
  ///
  /// [bearerToken], quando informado, é enviado como
  /// `Authorization: Bearer <token>`. [headers] complementa/sobrescreve os
  /// headers padrão.
  Future<Object?> get(
    String path, {
    Map<String, String>? headers,
    String? bearerToken,
  }) {
    return _send(
      (uri, mergedHeaders) => _httpClient.get(uri, headers: mergedHeaders),
      path,
      headers: headers,
      bearerToken: bearerToken,
    );
  }

  /// Executa `POST <baseUrl><path>` com corpo JSON opcional em [body].
  Future<Object?> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
    String? bearerToken,
  }) {
    return _send(
      (uri, mergedHeaders) => _httpClient.post(
        uri,
        headers: mergedHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
      path,
      headers: headers,
      bearerToken: bearerToken,
    );
  }

  /// Executa `PATCH <baseUrl><path>` com corpo JSON opcional em [body].
  Future<Object?> patch(
    String path, {
    Object? body,
    Map<String, String>? headers,
    String? bearerToken,
  }) {
    return _send(
      (uri, mergedHeaders) => _httpClient.patch(
        uri,
        headers: mergedHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
      path,
      headers: headers,
      bearerToken: bearerToken,
    );
  }

  /// Executa `PUT <baseUrl><path>` com corpo JSON opcional em [body].
  Future<Object?> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
    String? bearerToken,
  }) {
    return _send(
      (uri, mergedHeaders) => _httpClient.put(
        uri,
        headers: mergedHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
      path,
      headers: headers,
      bearerToken: bearerToken,
    );
  }

  /// Executa `DELETE <baseUrl><path>`.
  Future<Object?> delete(
    String path, {
    Map<String, String>? headers,
    String? bearerToken,
  }) {
    return _send(
      (uri, mergedHeaders) => _httpClient.delete(uri, headers: mergedHeaders),
      path,
      headers: headers,
      bearerToken: bearerToken,
    );
  }

  Future<Object?> _send(
    Future<http.Response> Function(Uri uri, Map<String, String> headers)
    request,
    String path, {
    Map<String, String>? headers,
    String? bearerToken,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl$path');
    final Map<String, String> mergedHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
      ...?headers,
    };

    late final http.Response response;
    try {
      response = await request(
        uri,
        mergedHeaders,
      ).timeout(ApiConfig.requestTimeout);
    } on TimeoutException {
      throw const ApiNetworkFailure(
        'O servidor demorou para responder. Tente novamente.',
      );
    } on SocketException {
      throw const ApiNetworkFailure(
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    } on http.ClientException {
      throw const ApiNetworkFailure(
        'Não foi possível completar a requisição. Tente novamente.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _decodeSuccess(response.body);
    }

    throw ApiErrorMapper.fromResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  Object? _decodeSuccess(String body) {
    if (body.isEmpty) {
      return null;
    }
    return jsonDecode(body);
  }

  /// Libera os recursos do cliente HTTP subjacente.
  void dispose() {
    _httpClient.close();
  }
}
