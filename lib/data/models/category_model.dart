import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String color;
  final String? icon;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
    };
  }

  Color get colorValue {
    final hex = color.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get iconData {
    switch (icon) {
      case 'work':
        return Icons.work_rounded;
      case 'person':
        return Icons.person_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'more_horiz':
        return Icons.more_horiz_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
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
