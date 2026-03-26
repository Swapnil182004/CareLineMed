import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/custom_colors.dart';

class OurProduct extends StatefulWidget {
  const OurProduct({super.key});

  @override
  State<OurProduct> createState() => _OurProductState();
}

class _OurProductState extends State<OurProduct> {
  int selectedCategoryIndex = 0;
  final List<String> categories = [
    "All",
    "Supplements",
    "Devices",
    "Personal Care",
    "Ayurvedic",
    "Baby Care"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primeryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Our Products",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: List.generate(categories.length, (index) {
                bool isSelected = selectedCategoryIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
                      });
                    },
                    hoverColor: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _productCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  "assets/paracitamol.jpg",
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "20% OFF",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Health Supplement",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "4.5 (120 reviews)",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                    label: const Text(
                      "Add to Bag",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}