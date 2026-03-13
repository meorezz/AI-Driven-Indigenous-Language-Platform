class Language {
  final String id;
  final String regionId;
  final String name;
  final String? nativeName;
  final int speakerCount;
  final String status;

  Language({
    required this.id,
    required this.regionId,
    required this.name,
    this.nativeName,
    this.speakerCount = 0,
    this.status = 'active',
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as String,
      regionId: json['region_id'] as String,
      name: json['name'] as String,
      nativeName: json['native_name'] as String?,
      speakerCount: json['speaker_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
    );
  }
}
