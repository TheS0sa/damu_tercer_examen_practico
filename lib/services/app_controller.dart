import 'package:flutter/foundation.dart';

import '../models/simpsons_character.dart';
import 'favorites_store.dart';
import 'simpsons_api.dart';

// Controlador que maneja el estado del catálogo, paginación y favoritos
class SimpsonsAppController extends ChangeNotifier {
  SimpsonsAppController({SimpsonsApi? api, FavoritesStore? favoritesStore})
    : _api = api ?? SimpsonsApi(),
      _favoritesStore = favoritesStore ?? FavoritesStore();

  final SimpsonsApi _api;
  final FavoritesStore _favoritesStore;
  List<SimpsonsCharacter> _characters = const [];
  List<SimpsonsCharacter> _allCharacters = const [];
  Map<int, SimpsonsCharacter> _favorites = {};
  int _currentPage = 1;
  int _pageCount = 1;
  bool _hasPrevious = false;
  bool _hasNext = false;
  bool _isLoading = true;
  bool _isSearchingAll = false;
  bool _allLoaded = false;
  bool _favoritesLoaded = false;
  String? _catalogError;
  String? _favoritesError;

  List<SimpsonsCharacter> get characters => _characters;
  List<SimpsonsCharacter> get allCharacters => _allCharacters;
  // Devuelve los favoritos ordenados por nombre
  List<SimpsonsCharacter> get favorites =>
      _favorites.values.toList(growable: false)
        ..sort((first, second) => first.name.compareTo(second.name));
  int get currentPage => _currentPage;
  int get pageCount => _pageCount;
  bool get hasPrevious => _hasPrevious;
  bool get hasNext => _hasNext;
  bool get isLoading => _isLoading;
  bool get isSearchingAll => _isSearchingAll;
  bool get allLoaded => _allLoaded;
  bool get favoritesLoaded => _favoritesLoaded;
  String? get catalogError => _catalogError;
  String? get favoritesError => _favoritesError;

  bool isFavorite(int id) => _favorites.containsKey(id);

  // Carga los favoritos guardados y la página 1 al iniciar
  Future<void> initialize() async {
    await loadFavorites();
    await loadPage(1);
  }

  // Lee los favoritos desde SharedPreferences
  Future<void> loadFavorites() async {
    try {
      final saved = await _favoritesStore.read();
      _favorites = {for (final character in saved) character.id: character};
      _favoritesError = null;
      _favoritesLoaded = true;
    } catch (_) {
      _favoritesError =
          'No se pudieron recuperar los favoritos guardados. Puedes reintentarlo.';
    }
    notifyListeners();
  }

  // Pide una página específica a la API y actualiza la pantalla
  Future<void> loadPage(int page) async {
    _isLoading = true;
    _catalogError = null;
    notifyListeners();

    try {
      final result = await _api.fetchCharacters(page);
      _characters = result.characters;
      _currentPage = result.page;
      _pageCount = result.pageCount;
      _hasPrevious = result.hasPrevious;
      _hasNext = result.hasNext;
    } on SimpsonsApiException catch (error) {
      _catalogError = error.message;
    } on FormatException {
      _catalogError = 'La información recibida no se pudo procesar.';
    } catch (_) {
      _catalogError =
          'Ocurrió un problema al cargar los personajes. Inténtalo de nuevo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Descarga todas las páginas en bloques de 10 para el buscador global
  Future<void> ensureAllCharactersLoaded() async {
    if (_allLoaded || _isSearchingAll) return;

    _isSearchingAll = true;
    notifyListeners();

    try {
      final total = _pageCount > 1 ? _pageCount : 60;
      final Map<int, SimpsonsCharacter> collected = {
        for (final c in _characters) c.id: c,
      };

      const int batchSize = 10;
      for (int start = 1; start <= total; start += batchSize) {
        final int end = (start + batchSize - 1 < total)
            ? start + batchSize - 1
            : total;

        final futures = <Future<CharacterPage>>[];
        for (int p = start; p <= end; p++) {
          if (p == _currentPage && _characters.isNotEmpty) continue;
          futures.add(_api.fetchCharacters(p));
        }

        final pages = await Future.wait(futures);
        for (final pageResult in pages) {
          for (final character in pageResult.characters) {
            collected[character.id] = character;
          }
        }
      }

      final fullList = collected.values.toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      _allCharacters = fullList;
      _allLoaded = true;
    } catch (_) {
      if (_allCharacters.isEmpty) {
        _allCharacters = _characters;
      }
    } finally {
      _isSearchingAll = false;
      notifyListeners();
    }
  }

  Future<SimpsonsCharacter> fetchCharacter(int id) => _api.fetchCharacter(id);

  // Agrega o quita un personaje de favoritos y guarda el cambio localmente
  Future<bool> toggleFavorite(SimpsonsCharacter character) async {
    if (!_favoritesLoaded && _favoritesError != null) return false;

    final updated = Map<int, SimpsonsCharacter>.from(_favorites);
    if (updated.containsKey(character.id)) {
      updated.remove(character.id);
    } else {
      updated[character.id] = character;
    }

    try {
      await _favoritesStore.write(updated.values);
    } catch (_) {
      _favoritesError =
          'No se pudo guardar el cambio de favoritos. Inténtalo de nuevo.';
      notifyListeners();
      return false;
    }

    _favorites = updated;
    _favoritesError = null;
    notifyListeners();
    return true;
  }
}