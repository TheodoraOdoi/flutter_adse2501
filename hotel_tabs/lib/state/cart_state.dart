// Class to remember and maintain the state of our shopping cart

// Import the required packages
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class  CartState extends ChangeNotifier
{
  CartState._();

  static final CartState instance = CartState._();
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount{return _items.fold(0, (total, item) => total + item.quantity);}

  double get totalAmount{return _items.fold(0, (total, item) => total + item.subtotal);}

  bool get isEmpty => _items.isEmpty;

  // Add food items
  void addItem(FoodItem foodItem)
  {
    final existingIndex = _items.indexWhere((item) => item.foodItem.id == foodItem.id);
    if(existingIndex == -1) {_items.add(CartItem(foodItem: foodItem));}
    else
      {
        final existingItem = _items[existingIndex];
        _items[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1,);
      }

    notifyListeners();
  }

  void increaseQuantity(String foodItemId)
  {
    final existingIndex = _items.indexWhere((item) => item.foodItem.id == foodItemId);
    if(existingIndex == -1) {return;}

    final existingItem = _items[existingIndex];
    _items[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1,);

    notifyListeners();
  }

  // Remove food items
  void removeItem(String foodItemId)
  {
    _items.removeWhere((item) => item.foodItem.id == foodItemId);
    notifyListeners();
  }

  void decreaseQuantity(String foodItemId)
  {
    final existingIndex = _items.indexWhere((item) => item.foodItem.id == foodItemId);
    if(existingIndex == -1) {return;}

    final existingItem = _items[existingIndex];

    if(existingItem.quantity == 1) {_items.removeAt(existingIndex);}
    else{_items[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity - 1);}

    notifyListeners();
  }

  // Clear the cart
  void clear()
  {
    _items.clear();
    notifyListeners();
  }
}