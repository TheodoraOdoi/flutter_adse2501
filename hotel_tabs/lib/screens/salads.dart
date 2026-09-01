// Screen to display burgers

// Import the flutter material package
import 'package:flutter/material.dart';

// Import our packages
import '../models/models.dart';
import '../widgets/food_item_list.dart';


class SaladsScreen extends StatelessWidget {
  const SaladsScreen({super.key});

  // List of salads
  static const _salads = [
    FoodItem(
        id: "corn_and_radish_salad",
        name: "Corn and Radish Salad",
        price: 600.0,
        imagePath: "assets/images/salads/salad1.jpg",
        rating: 4.5,
        description: "A fresh salad with corn and radish, perfect for a light meal.",
        category: FoodCategory.salad,
    ),
    FoodItem(
        id: "kiwi_and_strawberry_fruit_salad",
        name: "Fruit Salad",
        price: 700.0,
        imagePath: "assets/images/salads/salad2.jpg",
        rating: 4.6,
        description: "A refreshing fruit salad with a mix of seasonal fruits and a hint of mint.",
        category: FoodCategory.salad,
    ),
    FoodItem(
        id: "roasted_vegetable_salad",
        name: "Roasted Vegetable Salad",
        price: 800.0,
        imagePath: "assets/images/salads/salad3.jpg",
        rating: 4.7,
        description: "A delicious salad with roasted vegetables and a tangy vinaigrette dressing.",
        category: FoodCategory.salad,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FoodItemList(
      items: _salads,
      fallbackIcon: Icons.ramen_dining_rounded,
      fallbackColor: Colors.greenAccent.shade700,
    );
  }
}