import 'package:flutter/material.dart';
import '../models/furniture_item.dart';

class FurnitureSelector extends StatelessWidget {
  final Function(FurnitureItem) onFurnitureSelected;
  final FurnitureItem? selectedFurniture;

  const FurnitureSelector({
    super.key,
    required this.onFurnitureSelected,
    this.selectedFurniture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: FurnitureItem.allFurniture.length,
        itemBuilder: (context, index) {
          final furniture = FurnitureItem.allFurniture[index];
          final isSelected = selectedFurniture?.id == furniture.id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onFurnitureSelected(furniture),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.deepPurple
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      furniture.icon,
                      size: 32,
                      color: isSelected ? Colors.white : furniture.color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      furniture.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}