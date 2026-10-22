import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/simpsons_character.dart';

class SimpsonsApiException implements Exception {
  const SimpsonsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CharacterPage {
  const CharacterPage({
    required this.characters,
    required this.page,
    required this.pageCount,
    required this.hasPrevious,
    required this.hasNext,
  });

  final List<SimpsonsCharacter> characters;
  final int page;
  final int pageCount;
  final bool hasPrevious;
  final bool hasNext;
}

class SimpsonsApi {
  SimpsonsApi({http.Client? client}) : _client = client ?? http.Client();

  static const _host = 'thesimpsonsapi.com';
  final http.Client _client;

  Future<CharacterPage> fetchCharacters(int page) async {
    final uri = Uri.https(_host, '/api/characters', {'page': '$page'});
    final json = await _getJson(uri);
    final rawResults = json['results'];
    if (rawResults is! List) {
      throw const SimpsonsApiException(
        'La respuesta del catálogo no tiene el formato esperado.',
      );
    }

    final characters = rawResults
        .whereType<Map>()
        .map(
          (item) => SimpsonsCharacter.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    final pageCount = _readInt(json['pages']) ?? 1;

    return CharacterPage(
      characters: characters,
      page: page,
      pageCount: pageCount,
      hasPrevious: json['prev'] != null,
      hasNext: json['next'] != null,
    );
  }

  Future<SimpsonsCharacter> fetchCharacter(int id) async {
    final uri = Uri.https(_host, '/api/characters/$id');
    final json = await _getJson(uri);
    return SimpsonsCharacter.fromJson(json);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const SimpsonsApiException(
        'No hay conexión a internet. Revisa tu red e inténtalo de nuevo.',
      );
    } on TimeoutException {
      throw const SimpsonsApiException(
        'La API tardó demasiado en responder. Inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw const SimpsonsApiException(
        'No se pudo conectar con la API. Revisa tu conexión e inténtalo de nuevo.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SimpsonsApiException(
        'La API respondió con un error (${response.statusCode}). Inténtalo de nuevo.',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const SimpsonsApiException(
        'La API devolvió una respuesta que no se pudo leer.',
      );
    }
    if (decoded is! Map) {
      throw const SimpsonsApiException(
        'La API devolvió una respuesta que no se pudo leer.',
      );
    }
    return Map<String, dynamic>.from(decoded);
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    return value is String ? int.tryParse(value) : null;
  }
}
