class Club {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  // Factory method to create a Club object from a Firestore document
  factory Club.fromMap(Map<String, dynamic> map, String id) {
    return Club(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['logoUrl'] ?? '', // Assuming 'imageUrl' is a field in Firestore
    );
  }

  // Method to convert the Club object back to a map, useful for writing to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
