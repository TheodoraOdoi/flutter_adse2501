// Class to model a food item

class FoodItem
{
  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.rating,
    required this.description,
    required this.category,
  });

  final String id;
  final String name;
  final String imagePath;
  final String description;
  final double price;
  final double rating;
  final FoodCategory category;

}

// Enumeration of various food categories in our restaurant
enum FoodCategory {burger, dessert, pizza, salad,  drink }