class SimpsonsCharacter {
  const SimpsonsCharacter({
    required this.id,
    required this.name,
    required this.status,
    this.occupation,
    this.gender,
    this.age,
    this.birthdate,
    this.portraitPath,
    this.phrases = const [],
  });

  final int id;
  final String name;
  final String status;
  final String? occupation;
  final String? gender;
  final int? age;
  final String? birthdate;
  final String? portraitPath;
  final List<String> phrases;

  String? get portraitUrl {
    final path = portraitPath?.trim();
    if (path == null || path.isEmpty) return null;
    return 'https://cdn.thesimpsonsapi.com/500'
        '${path.startsWith('/') ? path : '/$path'}';
  }

  factory SimpsonsCharacter.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId');
    if (id == null) {
      throw const FormatException('El personaje no contiene un ID válido.');
    }

    final rawAge = json['age'];
    final age = rawAge is int ? rawAge : int.tryParse('$rawAge');
    final rawPhrases = json['phrases'];
    final phrases = rawPhrases is List
        ? rawPhrases.whereType<String>().toList(growable: false)
        : const <String>[];

    return SimpsonsCharacter(
      id: id,
      name: _readString(json['name']) ?? 'Personaje sin nombre',
      status: _readString(json['status']) ?? 'Desconocido',
      occupation: _readString(json['occupation']),
      gender: _readString(json['gender']),
      age: age,
      birthdate: _readString(json['birthdate']),
      portraitPath: _readString(json['portrait_path']),
      phrases: phrases,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'occupation': occupation,
    'gender': gender,
    'age': age,
    'birthdate': birthdate,
    'portrait_path': portraitPath,
    'phrases': phrases,
  };

  static String? _readString(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
