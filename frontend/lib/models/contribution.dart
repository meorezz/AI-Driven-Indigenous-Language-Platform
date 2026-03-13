class Contribution {
  final String id;
  final String languageId;
  final String? conceptId;
  final String contributorType;
  final String? audioUrl;
  final String? word;
  final String? translation;
  final String status;
  final DateTime createdAt;

  Contribution({
    required this.id,
    required this.languageId,
    this.conceptId,
    required this.contributorType,
    this.audioUrl,
    this.word,
    this.translation,
    this.status = 'pending',
    required this.createdAt,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'] as String,
      languageId: json['language_id'] as String,
      conceptId: json['concept_id'] as String?,
      contributorType: json['contributor_type'] as String,
      audioUrl: json['audio_url'] as String?,
      word: json['word'] as String?,
      translation: json['translation'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
