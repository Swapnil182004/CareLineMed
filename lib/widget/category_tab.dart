import 'package:flutter/material.dart';
import '../utils/custom_colors.dart';

class CategoryTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final TabController controller;

  const CategoryTab({
    super.key,
    required this.icon,
    required this.title,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final bool isSelected = controller.index == index;

        return Tab(
          height: 90, // Fixes the vertical overflow constraint
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? primeryColor.withOpacity(0.15) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isSelected ? primeryColor : Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? primeryColor : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}