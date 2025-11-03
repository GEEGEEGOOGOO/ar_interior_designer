import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onRotate;
  final VoidCallback onScaleUp;
  final VoidCallback onScaleDown;
  final VoidCallback onDelete;

  const ControlPanel({
    super.key,
    required this.onRotate,
    required this.onScaleUp,
    required this.onScaleDown,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Object Controls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.rotate_right,
                label: 'Rotate',
                onTap: onRotate,
                color: Colors.blue,
              ),
              _buildControlButton(
                icon: Icons.add,
                label: 'Scale +',
                onTap: onScaleUp,
                color: Colors.green,
              ),
              _buildControlButton(
                icon: Icons.remove,
                label: 'Scale -',
                onTap: onScaleDown,
                color: Colors.orange,
              ),
              _buildControlButton(
                icon: Icons.delete,
                label: 'Delete',
                onTap: onDelete,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}