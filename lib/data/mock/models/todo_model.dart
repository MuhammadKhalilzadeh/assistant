import 'package:assistant/data/models/category_model.dart';

class TodoModel {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final int priority; // 1 = high, 2 = medium, 3 = low
  final String? categoryId;
  final CategoryModel? category;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
    this.priority = 2,
    this.categoryId,
    this.category,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      priority: json['priority'] as int? ?? 2,
      categoryId: json['categoryId'] as String?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String().split('T').first,
      'priority': priority,
      'categoryId': categoryId,
      'category': category?.toJson(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String().split('T').first,
      'priority': priority,
      'categoryId': categoryId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String().split('T').first,
      'priority': priority,
      'categoryId': categoryId,
    };
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dueDate,
    int? priority,
    String? categoryId,
    CategoryModel? category,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
    );
  }
}
