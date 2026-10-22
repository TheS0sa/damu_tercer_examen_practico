import 'package:flutter/material.dart';

import '../models/simpsons_character.dart';
import '../services/app_controller.dart';
import '../services/simpsons_api.dart';
import '../widgets/character_image.dart';
import '../widgets/favorite_toggle.dart';

class CharacterDetailScreen extends StatefulWidget {
  const CharacterDetailScreen({
    super.key,
    required this.character,
    required this.controller,
  });

  final SimpsonsCharacter character;
  final SimpsonsAppController controller;

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late Future<SimpsonsCharacter> _detail;

  @override
  void initState() {
    super.initState();
    _detail = widget.controller.fetchCharacter(widget.character.id);
  }

  void _retry() {
    setState(() {
      _detail = widget.controller.fetchCharacter(widget.character.id);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Volver al catálogo',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text(
        'Ficha del personaje',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: [
        FavoriteToggle(
          character: widget.character,
          controller: widget.controller,
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: FutureBuilder<SimpsonsCharacter>(
      future: _detail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE7653B)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          final error = snapshot.error;
          final message = error is SimpsonsApiException
              ? error.message
              : 'No se pudo cargar la ficha. Inténtalo de nuevo.';
          return _DetailError(message: message, onRetry: _retry);
        }
        return _CharacterDetails(character: snapshot.data!);
      },
    ),
  );
}

class _CharacterDetails extends StatelessWidget {
  const _CharacterDetails({required this.character});

  final SimpsonsCharacter character;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: SizedBox(
              height: 300,
              child: CharacterImage(
                imageUrl: character.portraitUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            character.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF25243A),
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Center(child: _DetailStatus(status: character.status)),
          const SizedBox(height: 24),
          _InfoRow(label: 'Ocupación', value: character.occupation),
          _InfoRow(label: 'Género', value: character.gender),
          _InfoRow(
            label: 'Edad',
            value: character.age == null ? null : '${character.age} años',
          ),
          _InfoRow(label: 'Fecha de nacimiento', value: character.birthdate),
          if (character.phrases.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8A7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FRASE CÉLEBRE',
                    style: TextStyle(
                      color: Color(0xFF8A6223),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“${character.phrases.first}”',
                    style: const TextStyle(
                      color: Color(0xFF25243A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF777268),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'Sin información disponible',
            style: const TextStyle(
              color: Color(0xFF25243A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DetailStatus extends StatelessWidget {
  const _DetailStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(status),
    backgroundColor: const Color(0xFFE4F2E9),
    side: BorderSide.none,
    labelStyle: const TextStyle(
      color: Color(0xFF38775D),
      fontWeight: FontWeight.w800,
    ),
  );
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: Color(0xFFE7653B),
          ),
          const SizedBox(height: 14),
          const Text(
            'No se pudo cargar la ficha',
            style: TextStyle(
              color: Color(0xFF25243A),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}
