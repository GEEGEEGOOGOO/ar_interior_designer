import 'package:flutter/material.dart';

class FurnitureItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final FurnitureShape shape;
  final double defaultScale;

  const FurnitureItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.shape,
    this.defaultScale = 0.3,
  });

  static List<FurnitureItem> get allFurniture => [
        const FurnitureItem(
          id: 'chair',
          name: 'Chair',
          icon: Icons.chair,
          color: Colors.brown,
          shape: FurnitureShape.cube,
          defaultScale: 0.25,
        ),
        const FurnitureItem(
          id: 'table',
          name: 'Table',
          icon: Icons.table_restaurant,
          color: Colors.brown,
          shape: FurnitureShape.cube,
          defaultScale: 0.4,
        ),
        const FurnitureItem(
          id: 'lamp',
          name: 'Lamp',
          icon: Icons.lightbulb,
          color: Colors.yellow,
          shape: FurnitureShape.cylinder,
          defaultScale: 0.2,
        ),
        const FurnitureItem(
          id: 'sofa',
          name: 'Sofa',
          icon: Icons.weekend,
          color: Colors.blue,
          shape: FurnitureShape.cube,
          defaultScale: 0.5,
        ),
        const FurnitureItem(
          id: 'plant',
          name: 'Plant',
          icon: Icons.local_florist,
          color: Colors.green,
          shape: FurnitureShape.sphere,
          defaultScale: 0.2,
        ),
        const FurnitureItem(
          id: 'bed',
          name: 'Bed',
          icon: Icons.bed,
          color: Colors.red,
          shape: FurnitureShape.cube,
          defaultScale: 0.6,
        ),
      ];
}

enum FurnitureShape {
  cube,
  sphere,
  cylinder,
}