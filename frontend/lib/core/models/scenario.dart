class Scenario {
  final String id;
  final String title;
  final String context;
  final String category;
  final String? userId;
  final DateTime createdAt;

  Scenario({
    required this.id,
    required this.title,
    required this.context,
    required this.category,
    this.userId,
    required this.createdAt,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'],
      title: json['title'],
      context: json['context'],
      category: json['category'] ?? 'Genel',
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

