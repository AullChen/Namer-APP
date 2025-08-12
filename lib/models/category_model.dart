import 'package:uuid/uuid.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final String color;

  CategoryModel({
    String? id,
    required this.name,
    this.description = '',
    DateTime? createdAt,
    this.color = 'orange',
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      color: json['color'] ?? 'orange',
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    String? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}