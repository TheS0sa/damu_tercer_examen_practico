import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/simpsons_character.dart';

class FavoritesStore {
  static const _key = 'springfield_archive_favorites';

  Future<List<SimpsonsCharacter>> read() async {
    final preferences = await SharedPreferences.getInstance();
    final entries = preferences.getStringList(_key) ?? const <String>[];
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
