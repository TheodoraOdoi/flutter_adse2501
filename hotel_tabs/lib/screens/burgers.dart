// Screen to display burgers

// Import the flutter material package
import 'package:flutter/material.dart';

// Import our packages
import '../models/models.dart';
import '../widgets/food_item_list.dart';


class BurgersScreen extends StatelessWidget {
  const BurgersScreen({super.key});

  // List of burgers
  static const _burgers = [
    FoodItem(
        id: "chicken_burger",
        name: "Chicken Burger",
        price: 900.0,
        imagePath: "assets/images/burgers/burger1.jpg",
        rating: 4.5,
        description: "Our chicken burger features a seasoned chicken patty—either crispy fried or grilled—set inside a soft, toasted bun",
        category: FoodCategory.burger,
    ),
    FoodItem(
        id: "classic_beef_burger",
        name: "Beef Burger",
        price: 850.0,
        imagePath: "assets/images/burgers/burger2.jpg",
        rating: 4.7,
        description: "Our Classic beef burger features a juicy, pan-seared or grilled ground beef patty with an 80/20 meat-to-fat ratio",
        category: FoodCategory.burger,
    ),
    FoodItem(
        id: "chicken_beef_burger",
        name: "King Size Burger",
        price: 1500.0,
        imagePath: "assets/images/burgers/burger3.jpg",
        rating: 4.8,
        description: "Our king-sized chicken-beef burger is a massive, towering sandwich packed with both a thick beef patty and a crispy or grilled chicken breast.",
        category: FoodCategory.burger,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FoodItemList(
      items: _burgers,
      fallbackIcon: Icons.lunch_dining_outlined,
      fallbackColor: Colors.orange.shade50,
    );
  }
}