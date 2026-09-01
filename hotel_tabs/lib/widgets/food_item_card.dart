// This will be used to display food or drink item
// in their respective screens

// Import the flutter material package
import 'package:flutter/material.dart';

// Import our packages
import '../models/models.dart';
import '../state/cart_state.dart';

class FoodItemCard extends StatelessWidget
{
  //=========================================================================
  // Fields
  //=========================================================================
  final FoodItem foodItem;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final bool compact;

  //=========================================================================
  // Constructor
  //=========================================================================
  const FoodItemCard(
      {
        super.key,
        required this.foodItem,
        this.fallbackIcon = Icons.fastfood_rounded,
        this.fallbackColor = Colors.black,
        this.compact = false,
      });

  // Instance method to format the price
  String get formattedPrice
  {
    final hasDecimal = foodItem.price.truncateToDouble() != foodItem.price;
    return "Kes. ${foodItem.price.toStringAsFixed(hasDecimal ? 2 : 0)}";
  }

  @override
  Widget build(BuildContext context) {
    // Our layout is responsive depending on the screen orientation
    return LayoutBuilder(
        builder: (context, constraints)
            {
              final useHorizontalLayout = constraints.maxWidth > 600;

              if(useHorizontalLayout)
                {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 260, child: _buildImage(height: 190)),
                      const SizedBox(width: 20,),
                      Expanded(child: _buildDetails(context)),
                    ],
                  );
                }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildImage(height: compact? 130 : (constraints.maxWidth > 4200 ? 220 : 170),),
                  const SizedBox(height: 20,),
                  _buildDetails(context),
                ],
              );
            }
    );
  }

  // Build image widget
  Widget _buildImage({required double height})
  {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        foodItem.imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: fallbackColor ?? Colors.grey.shade200,
            alignment: Alignment.center,
            child: Icon(fallbackIcon, size: 64, color: Colors.grey),
          );
        },
      ),
    );
  }

  // Build details widget
  Widget _buildDetails(BuildContext context)
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(foodItem.name, style: Theme.of(context).textTheme.titleLarge,),
        const SizedBox(height: 6,),
        Text(formattedPrice, style: Theme.of(context).textTheme.titleMedium,),
        const SizedBox(height: 8,),
        Row(
          children: [
            ...List.generate(5, _buildRatingIcon),
            const SizedBox(width: 8,),
            Text(foodItem.rating.toStringAsFixed(1)),
          ],
        ),
        const SizedBox(height: 12,),
        Text(
          foodItem.description,
          maxLines: compact ? 2 : null,
          overflow: compact ? TextOverflow.ellipsis : null,
        ),
        const SizedBox(height: 12,),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(onPressed: () {
            CartState.instance.addItem(foodItem);

            ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text("${foodItem.name} added to cart")),
            );
          },
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text("Add to Cart"),
          ),
        ),
      ],
    );
  }

  // Widget to display the food/drinks rating
  Widget _buildRatingIcon(int index)
  {
    final starPosition = index + 1;

    if(foodItem.rating >= starPosition)
      {return const Icon(Icons.star_rounded, color: Colors.amber, size: 20);}

    if(foodItem.rating >= starPosition - .5)
      {return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 20);}

    return const Icon(Icons.star_border_rounded, color: Colors.amber, size: 20);
  }
}
