// lib/project_model.dart

class Project {
  final String id;
  final String name;
  final String description;
  final int progress;
  final String? imageUrl; // Puede ser nulo si no suben foto

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.progress,
    this.imageUrl,
  });

  // Factory para convertir el JSON de la API a un objeto Dart
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // parseamos a int por si MockAPI lo devuelve como String
      progress: int.tryParse(json['progress'].toString()) ?? 0, 
      imageUrl: json['imageUrl'],
    );
  }
}