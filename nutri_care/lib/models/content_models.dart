import 'package:cloud_firestore/cloud_firestore.dart';

class Guide {
  final String id;
  final String title;
  final String description;
  final String content;
  final String category;
  final String? imageUrl;
  final String creatorId;
  final DateTime createdAt;

  Guide({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    this.imageUrl,
    required this.creatorId,
    required this.createdAt,
  });

  factory Guide.fromMap(Map<String, dynamic> map, String id) {
    return Guide(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'],
      creatorId: map['creatorId'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'content': content,
    'category': category,
    'imageUrl': imageUrl,
    'creatorId': creatorId,
    'createdAt': createdAt,
  };
}

class NutritionGuide {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String creatorId;
  final DateTime createdAt;

  NutritionGuide({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.creatorId,
    required this.createdAt,
  });

  factory NutritionGuide.fromMap(String id, Map<String, dynamic> map) {
    return NutritionGuide(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      creatorId: map['creatorId'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'creatorId': creatorId,
    'createdAt': createdAt,
  };
}

class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String creatorId;
  final DateTime createdAt;
  final List<Ingredient> ingredients;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.creatorId,
    required this.createdAt,
    required this.ingredients,
  });

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      creatorId: map['creatorId'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
      ingredients: (map['ingredients'] as List<dynamic>? ?? [])
          .map((e) => Ingredient.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'creatorId': creatorId,
    'createdAt': createdAt,
    'ingredients': ingredients.map((e) => e.toMap()).toList(),
  };
}

class Ingredient {
  final String name;
  final String amount;

  Ingredient({required this.name, required this.amount});

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(name: map['name'] ?? '', amount: map['amount'] ?? '');
  }

  Map<String, dynamic> toMap() => {'name': name, 'amount': amount};
}

class HealthAlert {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final DateTime createdAt;

  HealthAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.createdAt,
  });

  factory HealthAlert.fromMap(String id, Map<String, dynamic> map) {
    return HealthAlert(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      creatorId: map['creatorId'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'creatorId': creatorId,
    'createdAt': createdAt,
  };
}
