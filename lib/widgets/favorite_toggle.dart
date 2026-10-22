import 'package:flutter/material.dart';

import '../models/simpsons_character.dart';
import '../services/app_controller.dart';

class FavoriteToggle extends StatelessWidget {
  const FavoriteToggle({
    super.key,
    required this.character,
    required this.controller,
  });

  final SimpsonsCharacter character;
  final SimpsonsAppController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final isFavorite = controller.isFavorite(character.id);
      return IconButton(
        tooltip: isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
        onPressed:
            !controller.favoritesLoaded || controller.favoritesError != null
            ? null
            : () async {
                final saved = await controller.toggleFavorite(character);
                if (!saved && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se pudo actualizar tu colección.'),
                    ),
                  );
                }
              },
        icon: Icon(
          isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: isFavorite ? const Color(0xFFE7653B) : const Color(0xFF8C877E),
        ),
      );
    },
  );
}
