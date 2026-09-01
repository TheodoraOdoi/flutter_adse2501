// Screen to display drinks

// Import the flutter material package
import 'package:flutter/material.dart';

// Import our packages
import '../models/models.dart';
import '../widgets/food_item_list.dart';


class DrinksScreen extends StatelessWidget {
  const DrinksScreen({super.key});

  // List of drinks
  static const _drinks = [
    FoodItem(
        id: "strawberry_punch",
        name: "Strawberry Punch",
        price: 500.0,
        imagePath: "assets/images/drinks/drink1.jpg",
        rating: 4.5,
        description: "A refreshing blend of fresh strawberries and citrus juices, perfect for a hot day.",
        category: FoodCategory.drink,
    ),
    FoodItem(
        id: "sprite_mint_mojito",
        name: "Sprite Mint Mojito",
        price: 450.0,
        imagePath: "assets/images/drinks/drink2.jpg",
        rating: 4.7,
        description: "A refreshing blend of Sprite, fresh mint leaves, and a hint of lime juice.",
        category: FoodCategory.drink,
    ),
    FoodItem(
        id: "pina_colada",
        name: "Pina Colada",
        price: 500.0,
        imagePath: "assets/images/drinks/drink3.jpg",
        rating: 4.8,
        description: "A refreshing tropical drink with a creamy, milky texture and a hint of pineapple.",
        category: FoodCategory.drink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FoodItemList(
      items: _drinks,
      fallbackIcon: Icons.local_drink_outlined,
      fallbackColor: Colors.orange.shade50,
    );
  }
}