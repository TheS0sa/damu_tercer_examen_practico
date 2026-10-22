import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movilapp/models/simpsons_character.dart';
import 'package:movilapp/services/favorites_store.dart';
import 'package:movilapp/services/simpsons_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('parses optional fields and builds an HTTPS portrait URL', () {
    final character = SimpsonsCharacter.fromJson({
      'id': 3,
      'name': 'Bart Simpson',
      'status': 'Alive',
      'occupation': null,
      'gender': 'Male',
      'age': null,
      'portrait_path': '/character/3.webp',
      'phrases': ['¡Ay Caramba!'],
    });

    expect(character.name, 'Bart Simpson');
    expect(character.occupation, isNull);
    expect(character.age, isNull);
    expect(
      character.portraitUrl,
      'https://cdn.thesimpsonsapi.com/500/character/3.webp',
    );
    expect(character.phrases, ['¡Ay Caramba!']);
  });

  test('uses safe defaults when fields are absent', () {
    final character = SimpsonsCharacter.fromJson({'id': '8'});

    expect(character.id, 8);
    expect(character.name, 'Personaje sin nombre');
    expect(character.status, 'Desconocido');
    expect(character.portraitUrl, isNull);
    expect(character.phrases, isEmpty);
  });

  test('rejects a character without a valid ID', () {
    expect(
      () => SimpsonsCharacter.fromJson({'name': 'Personaje desconocido'}),
      throwsFormatException,
    );
  });

  test('loads the API page and reads its pagination metadata', () async {
    late Uri requestedUri;
    final api = SimpsonsApi(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"count":1182,"pages":60,"next":"page=2","prev":null,'
          '"results":[{"id":1,"name":"Homer Simpson","status":"Alive",'
          '"occupation":"Safety Inspector"}]}',
          200,
        );
      }),
    );

    final page = await api.fetchCharacters(1);

    expect(requestedUri.scheme, 'https');
    expect(requestedUri.path, '/api/characters');
    expect(requestedUri.queryParameters['page'], '1');
    expect(page.characters.single.name, 'Homer Simpson');
    expect(page.pageCount, 60);
    expect(page.hasPrevious, isFalse);
    expect(page.hasNext, isTrue);
  });

  test('persists favorite character IDs and details between reads', () async {
    SharedPreferences.setMockInitialValues({});
    const character = SimpsonsCharacter(
      id: 42,
      name: 'Springfield Resident',
      status: 'Alive',
    );
    final store = FavoritesStore();

    await store.write([character]);
    final saved = await store.read();

    expect(saved, hasLength(1));
    expect(saved.single.id, character.id);
    expect(saved.single.name, character.name);
  });
}
