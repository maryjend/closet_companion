class Outfit {
  final String imagePath;
  final String date;
  final String category;
  final String notes;
  final List<String> tags;

  Outfit({
    required this.imagePath,
    required this.date,
    required this.category,
    required this.notes,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'date': date,
        'category': category,
        'notes': notes,
        'tags': tags,
      };

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
        imagePath: json['imagePath'],
        date: json['date'],
        category: json['category'],
        notes: json['notes'],
        tags: List<String>.from(json['tags'] ?? []),
      );
}
