// Class to model a cart item

//import 'package:hotel_tabs/models/food_item.dart';
import 'food_item.dart';

class CartItem
{
  // Constant to be used in the cart
  final FoodItem foodItem;
  final int quantity;

  // Instance method to calculate the subtotal for each item e.g 3 pizzas @ 1200 = 3600
  double get subtotal => foodItem.price * quantity;

  //================================================================
// Constructors
//==================================================================
const CartItem({required this.foodItem, this.quantity = 1});

CartItem copyWith({FoodItem? foodItem, int? quantity})
{
  return CartItem(
    foodItem: foodItem ?? this.foodItem,
    quantity: quantity ?? this.quantity,
  );
}
}