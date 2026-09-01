// Screen to display Cart

// Import the flutter material package
import 'package:flutter/material.dart';

// Import our custom packages
import '../models/models.dart';
import '../state/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartState.instance,
      builder: (context, child) 
      {
        final cart = CartState.instance;

        if(cart.isEmpty)
        {
          return const Center(child: Text("Your cart is empty. Add something tasty first.🥪"));
        }
        return LayoutBuilder(
          builder:(context, constraints)
          {
            final useSideBySideLayout = constraints.maxWidth > 700;

            return Padding(
                padding: const EdgeInsets.all(16.0),
                child: useSideBySideLayout
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _CartItemsList(items: cart.items)),
                    const SizedBox(width: 16,),
                    SizedBox(width: 320, child: _CartSummary(cart: cart)),
                  ],
                ) :
                Column(
                  children: [
                    Expanded(child: _CartItemsList(items: cart.items),),
                    const Divider(height: 32),
                    _CartSummary(cart: cart),
                  ],
                ),
            );
          },
        );
      },
    );
  }
}

// Private CartItemsList class
class _CartItemsList extends StatelessWidget {
  const _CartItemsList({required this.items});

  // field to be used in the class
  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index)
          {
            return _CartItemTile(cartItem: items[index]);
          },
      separatorBuilder: (context, index) => const SizedBox(height: 12.0),
      itemCount: items.length,
    );
  }
}

// Private class to represent individual food items in the cart
class _CartItemTile extends StatelessWidget {
  // Field to hold a cart item
  final CartItem cartItem;

  const _CartItemTile({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    // food item variable
    final foodItem = cartItem.foodItem;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                foodItem.imagePath,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(
                        Icons.fastfood_rounded, color: Colors.grey),
                  );
                },
              ),
            ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(foodItem.name, style: Theme.of(context).textTheme.titleLarge,),
                    const SizedBox(height: 4),
                    Text(_formatPrice(foodItem.price)),
                    const SizedBox(height: 8,),
                    Text("Subtotal: ${_formatPrice(cartItem.subtotal)}"),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                      onPressed: () {CartState.instance.increaseQuantity(foodItem.id);},
                      icon: const Icon(Icons.add_circle_rounded),
                  ),
                  Text("${cartItem.quantity}"),
                  IconButton(
                      onPressed: () {CartState.instance.decreaseQuantity(foodItem.id);},
                      icon: const Icon(Icons.remove_circle_rounded),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
} 

// Function to format the price of foods/drinks and subtotal
String _formatPrice(double price)
{
  final hasDecimal = price.truncateToDouble() != price;
  return "Kes. ${price.toStringAsFixed(hasDecimal ? 2 : 0)}";
}

// Private class to display the cart summary(all items ordered & the total amount due)
class _CartSummary extends StatelessWidget {
  // Field to hold the cart's state
  final CartState cart;

  const _CartSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Order Summary", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Items"), Text(" : ${cart.itemCount}")
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount Due"),
                Text(_formatPrice(cart.totalAmount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            OutlinedButton.icon(
                onPressed: cart.clear,
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text("Clear Cart"),
            ),
          ],
        ),
      ),
    );
  }
}


