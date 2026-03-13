class Concept {
  final String id;
  final String categoryId;
  final String languageId;
  final String word;
  final String translation;
  final String? pronunciationGuide;
  final String? audioUrl;
  final String? imageUrl;

  Concept({
    required this.id,
    required this.categoryId,
    required this.languageId,
    required this.word,
    required this.translation,
    this.pronunciationGuide,
    this.audioUrl,
    this.imageUrl,
  });

  factory Concept.fromJson(Map<String, dynamic> json) {
    return Concept(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      languageId: json['language_id'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      pronunciationGuide: json['pronunciation_guide'] as String?,
      audioUrl: json['audio_url'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
