import 'package:english_words/english_words.dart';
import 'package:uuid/uuid.dart';

class WordPairModel {
  final String id;
  final WordPair wordPair;
  final DateTime createdAt;
  final List<String> categories;
  final int rating;

  WordPairModel({
    String? id,
    required this.wordPair,
    DateTime? createdAt,
    List<String>? categories,
    this.rating = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        categories = categories ?? ['未分类'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first': wordPair.first,
      'second': wordPair.second,
      'createdAt': createdAt.toIso8601String(),
      'categories': categories,
      'rating': rating,
    };
  }

  factory WordPairModel.fromJson(Map<String, dynamic> json) {
    return WordPairModel(
      id: json['id'],
      wordPair: WordPair(json['first'], json['second']),
      createdAt: DateTime.parse(json['createdAt']),
      categories: List<String>.from(json['categories']),
      rating: json['rating'] ?? 0,
    );
  }

  WordPairModel copyWith({
    String? id,
    WordPair? wordPair,
    DateTime? createdAt,
    List<String>? categories,
    int? rating,
  }) {
    return WordPairModel(
      id: id ?? this.id,
      wordPair: wordPair ?? this.wordPair,
      createdAt: createdAt ?? this.createdAt,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordPairModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}