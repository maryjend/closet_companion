class Outfit {
  final String imagePath;
  final String date;
  final String category;
  final String notes;

  Outfit({
    required this.imagePath,
    required this.date,
    required this.category,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'date': date,
        'category': category,
        'notes': notes,
      };

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
        imagePath: json['imagePath'],
        date: json['date'],
        category: json['category'],
        notes: json['notes'],
      );
}
