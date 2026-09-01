// Import the flutter material package
import 'package:flutter/material.dart';

// Import our packages
import '../models/models.dart';
import '../widgets/food_item_list.dart';


class PizzasScreen extends StatelessWidget {
  const PizzasScreen({super.key});

  // List of pizzas
  static const _pizzas = [
    FoodItem(
        id: "pepperoni_pizza",
        name: "Pepperoni Pizza",
        price: 1250.0,
        imagePath: "assets/images/pizzas/pizza1.jpg",
        rating: 4.5,
        description: "Our pepperoni pizza features a generous amount of spicy pepperoni slices on top of our signature tomato sauce and mozzarella cheese.",
        category: FoodCategory.pizza,
    ),
    FoodItem(
        id: "hawaiian_pizza",
        name: "Hawaiian Pizza",
        price: 1450.0,
        imagePath: "assets/images/pizzas/pizza2.jpg",
        rating: 4.7,
        description: "Our Hawaiian pizza features a delicious combination of ham, pineapple, and mozzarella cheese.",
        category: FoodCategory.pizza,
    ),
    FoodItem(
        id: "margherita_pizza",
        name: "Margherita Pizza",
        price: 1500.0,
        imagePath: "assets/images/pizzas/pizza3.jpg",
        rating: 4.8,
        description: " Our margherita pizza is a classic Italian pizza made with fresh mozzarella cheese, tomato sauce, and fresh basil leaves.",
        category: FoodCategory.pizza,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FoodItemList(
      items: _pizzas,
      fallbackIcon: Icons.local_pizza_outlined,
      fallbackColor: Colors.redAccent.shade700,
    );
  }
}