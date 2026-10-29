import 'package:flutter/material.dart';

import '../models/simpsons_character.dart';
import '../services/app_controller.dart';
import '../widgets/character_image.dart';
import '../widgets/favorite_toggle.dart';
import 'character_detail_screen.dart';
import 'login_screen.dart';

class CatalogHomeScreen extends StatefulWidget {
  const CatalogHomeScreen({super.key, required this.controller});

  final SimpsonsAppController controller;

  @override
  State<CatalogHomeScreen> createState() => _CatalogHomeScreenState();
}

class _CatalogHomeScreenState extends State<CatalogHomeScreen> {
  final _searchController = TextEditingController();
  int _selectedTab = 0; // 0 = Catálogo, 1 = Favoritos
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Actualiza el texto de búsqueda y carga todas las páginas si hace falta
  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    setState(() => _query = trimmed);
    if (trimmed.isNotEmpty) {
      widget.controller.ensureAllCharactersLoaded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE7653B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.movie_filter_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARCHIVO DE SPRINGFIELD',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Un catálogo muy animado',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF77726B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Botón para cerrar sesión y regresar al login
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(controller: widget.controller),
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE7653B),
                side: const BorderSide(color: Color(0xFFE9E0D0)),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) => _ArchiveBanner(
                      isFavorites: _selectedTab == 1,
                      favoriteCount: widget.controller.favorites.length,
                    ),
                  ),
                ),
                // Solo muestra el buscador en la pestaña de catálogo
                if (_selectedTab == 0) _buildSearch(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) =>
                        _selectedTab == 0 ? _buildCatalog() : _buildFavorites(),
                  ),
                ),
                // Oculta la paginación mientras se está buscando un personaje
                if (_selectedTab == 0 && _query.isEmpty) _buildPagination(),
              ],
            ),
          ),
        ),
      ),
      // Barra inferior para cambiar entre Catálogo y Favoritos
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() => _selectedTab = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFE8A7),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }

  // Caja de texto para buscar personajes por nombre
  Widget _buildSearch() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Busca un personaje en todo el catálogo...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
        ),
      );

  // Construye la lista del catálogo y maneja estados de carga o error
  Widget _buildCatalog() {
    final controller = widget.controller;
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE7653B)),
      );
    }

    if (controller.catalogError != null) {
      return _MessagePanel(
        icon: Icons.wifi_off_rounded,
        title: 'No se pudo conectar',
        message: controller.catalogError!,
        actionLabel: 'Reintentar',
        onAction: () => controller.loadPage(controller.currentPage),
      );
    }

    // Espera mientras descarga todas las páginas para el buscador global
    if (_query.isNotEmpty && controller.isSearchingAll) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFE7653B)),
            SizedBox(height: 14),
            Text(
              'Buscando en todas las páginas de Springfield...',
              style: TextStyle(
                color: Color(0xFF77726B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Filtra sin importar mayúsculas o minúsculas
    final normalizedQuery = _query.toLowerCase();
    final sourceList = _query.isNotEmpty && controller.allLoaded
        ? controller.allCharacters
        : controller.characters;

    final results = _query.isEmpty
        ? sourceList
        : sourceList
              .where(
                (character) =>
                    character.name.toLowerCase().contains(normalizedQuery),
              )
              .toList(growable: false);

    if (results.isEmpty) {
      return _MessagePanel(
        icon: _query.isEmpty ? Icons.movie_creation_outlined : Icons.search_off,
        title: _query.isEmpty ? 'Esta página está vacía' : 'Sin coincidencias',
        message: _query.isEmpty
            ? 'Prueba otra página para descubrir más personajes.'
            : 'No encontramos ningún personaje con "$_query" en todo el catálogo.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          CharacterCard(character: results[index], controller: controller),
    );
  }

  // Muestra la lista de personajes guardados en favoritos
  Widget _buildFavorites() {
    final controller = widget.controller;
    if (controller.favoritesError != null) {
      return _MessagePanel(
        icon: Icons.bookmark_remove_outlined,
        title: 'No se cargaron tus favoritos',
        message: controller.favoritesError!,
        actionLabel: 'Reintentar',
        onAction: controller.loadFavorites,
      );
    }

    if (!controller.favoritesLoaded) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE7653B)),
      );
    }

    if (controller.favorites.isEmpty) {
      return const _MessagePanel(
        icon: Icons.bookmark_border_rounded,
        title: '¡Tu colección está esperando!',
        message:
            'Guarda personajes desde el catálogo y aparecerán aquí, incluso cuando vuelvas a abrir la app.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 16),
      itemCount: controller.favorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => CharacterCard(
        character: controller.favorites[index],
        controller: controller,
      ),
    );
  }

  // Botones Anterior y Siguiente para cambiar de página
  Widget _buildPagination() {
    final controller = widget.controller;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: controller.isLoading || !controller.hasPrevious
                  ? null
                  : () => controller.loadPage(controller.currentPage - 1),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Anterior'),
            ),
            Expanded(
              child: Text(
                'Página ${controller.currentPage} de ${controller.pageCount}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF77726B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: controller.isLoading || !controller.hasNext
                  ? null
                  : () => controller.loadPage(controller.currentPage + 1),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Siguiente'),
              iconAlignment: IconAlignment.end,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveBanner extends StatelessWidget {
  const _ArchiveBanner({
    required this.isFavorites,
    required this.favoriteCount,
  });

  final bool isFavorites;
  final int favoriteCount;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF29283E),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFavorites ? 'TU COLECCIÓN' : 'ARCHIVO DE SPRINGFIELD',
              style: const TextStyle(
                color: Color(0xFFFFD86A),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              isFavorites
                  ? '$favoriteCount personaje/s guardado/s'
                  : 'Historias en cada esquina.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isFavorites
                  ? 'Tus elegidos, siempre a mano.'
                  : 'Conoce a los habitantes de la ciudad.',
              style: const TextStyle(color: Color(0xFFD7D4E1), fontSize: 13),
            ),
          ],
        ),
      );
}

// Tarjeta individual de cada personaje en la lista
class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.character,
    required this.controller,
  });

  final SimpsonsCharacter character;
  final SimpsonsAppController controller;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Al tocar la tarjeta abre la pantalla de detalle
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => CharacterDetailScreen(
                character: character,
                controller: controller,
              ),
            ),
          ),
          child: SizedBox(
            height: 132,
            child: Row(
              children: [
                SizedBox(
                  width: 104,
                  height: double.infinity,
                  child: CharacterImage(imageUrl: character.portraitUrl),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          character.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF25243A),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        _StatusBadge(status: character.status),
                        const SizedBox(height: 7),
                        Text(
                          character.occupation ?? 'Ocupación desconocida',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF77726B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FavoriteToggle(character: character, controller: controller),
              ],
            ),
          ),
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE4F2E9),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          status,
          style: const TextStyle(
            color: Color(0xFF38775D),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

// Panel reutilizable para mostrar mensajes de vacío o errores de red
class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: const Color(0xFFE7653B)),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF25243A),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF77726B), height: 1.45),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      );
}