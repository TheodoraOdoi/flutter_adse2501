// Screen to display desserts

// Import the flutter material package
import 'package:flutter/material.dart';

// Import out packages
import '../models/models.dart';
import '../widgets/food_item_list.dart';

class DessertsScreen extends StatelessWidget {
  const DessertsScreen({super.key});

  // List of desserts
  static const _desserts = [
    FoodItem(
        id: "strawberry_cheesecake",
        name: "Strawberry Cheesecake",
        price: 880.0,
        imagePath: "assets/images/desserts/dessert1.jpg",
        rating: 4.5,
        description: "Our strawberry cheesecake features a buttery graham cracker crust, creamy cheesecake filling, and fresh strawberry topping.",
        category: FoodCategory.dessert,
    ),
    FoodItem(
        id: "vanilla_ice_cream_sundae",
        name: "Vanilla Ice Cream Sundae",
        price: 300.0,
        imagePath: "assets/images/desserts/dessert2.jpg",
        rating: 4.7,
        description: "Our vanilla ice-cream sundae is a classic treat made with real vanilla beans, providing a creamy and smooth texture.",
        category: FoodCategory.dessert,
    ),
    FoodItem(
        id: "chocolate__fudge_cake",
        name: "Chocolate Fudge Cake",
        price: 650.0,
        imagePath: "assets/images/desserts/dessert3.jpg",
        rating: 4.8,
        description: "A rich and indulgent dessert made with layers of chocolate cake and decadent fudge frosting.",
        category: FoodCategory.dessert,
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return FoodItemList(
      items: _desserts,
      fallbackIcon: Icons.lunch_dining_outlined,
      fallbackColor: Colors.orange.shade50,
    );
  }
}