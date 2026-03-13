class Region {
  final String id;
  final String name;
  final String? description;
  final Map<String, dynamic>? mapCoordinates;

  Region({
    required this.id,
    required this.name,
    this.description,
    this.mapCoordinates,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      mapCoordinates: json['map_coordinates'] as Map<String, dynamic>?,
    );
  }
}
