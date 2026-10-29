import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/simpsons_character.dart';

// Guarda y recupera los personajes favoritos en la memoria local
class FavoritesStore {
  static const _key = 'simpsons_favorites_v1';

  // Lee la lista de textos JSON guardada y la convierte a objetos SimpsonsCharacter
  Future<List<SimpsonsCharacter>> read() async {
    final preferences = await SharedPreferences.getInstance();
    final entries = preferences.getStringList(_key) ?? const [];
    final favorites = <int, SimpsonsCharacter>{};

    for (final entry in entries) {
      final dynamic decoded;
      try {
        decoded = jsonDecode(entry);
      } on FormatException {
        throw const FormatException(
          'Los favoritos guardados están dañados y no se pudieron leer.',
        );
      }

      if (decoded is! Map) {
        throw const FormatException(
          'Los favoritos guardados tienen un formato inválido.',
        );
      }

      final character = SimpsonsCharacter.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      favorites[character.id] = character;
    }

    return favorites.values.toList(growable: false);
  }

  // Convierte los personajes favoritos a JSON y los guarda en SharedPreferences
  Future<void> write(Iterable<SimpsonsCharacter> favorites) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = favorites.map(
      (character) => jsonEncode(character.toJson()),
    );

    final saved = await preferences.setStringList(_key, entries.toList());
    if (!saved) {
      throw StateError('No se pudieron guardar los favoritos.');
    }
  }
}