/// Data model representing a single idiom entry in the database.
class Idiom {
  final int id;
  final String idiom;
  final String meaning;
  final String explanation;
  final String example;
  final String usage; // 'formal', 'informal', 'both'
  final String category;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String origin;
  final List<String> related;
  bool isFavorite;

  Idiom({
    required this.id,
    required this.idiom,
    required this.meaning,
    required this.explanation,
    required this.example,
    required this.usage,
    required this.category,
    required this.difficulty,
    this.origin = '',
    this.related = const [],
    this.isFavorite = false,
  });

  /// Create an Idiom from a JSON map (database row or JSON asset).
  factory Idiom.fromJson(Map<String, dynamic> json) {
    return Idiom(
      id: json['id'] as int,
      idiom: json['idiom'] as String,
      meaning: json['meaning'] as String,
      explanation: json['explanation'] as String,
      example: json['example'] as String,
      usage: json['usage'] as String? ?? 'both',
      category: json['category'] as String,
      difficulty: json['difficulty'] as String? ?? 'intermediate',
      origin: json['origin'] as String? ?? '',
      related: json['related'] != null
          ? List<String>.from(json['related'] as List)
          : [],
      isFavorite: (json['is_favorite'] as int?) == 1,
    );
  }

  /// Convert to a JSON-compatible map for database insertion.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idiom': idiom,
      'meaning': meaning,
      'explanation': explanation,
      'example': example,
      'usage': usage,
      'category': category,
      'difficulty': difficulty,
      'origin': origin,
      'related': related.join('|'),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// Create a copy with optional field overrides.
  Idiom copyWith({
    int? id,
    String? idiom,
    String? meaning,
    String? explanation,
    String? example,
    String? usage,
    String? category,
    String? difficulty,
    String? origin,
    List<String>? related,
    bool? isFavorite,
  }) {
    return Idiom(
      id: id ?? this.id,
      idiom: idiom ?? this.idiom,
      meaning: meaning ?? this.meaning,
      explanation: explanation ?? this.explanation,
      example: example ?? this.example,
      usage: usage ?? this.usage,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      origin: origin ?? this.origin,
      related: related ?? this.related,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Idiom && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Idiom(id: $id, idiom: "$idiom")';
}
