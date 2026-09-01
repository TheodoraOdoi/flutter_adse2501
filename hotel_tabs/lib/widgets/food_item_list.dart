// This will be used to display food or drink item
// in their respective screens

// Import the flutter material package
import 'package:flutter/material.dart';

// Import our packages
import '../models/models.dart';
import '../widgets/food_item_card.dart';

class FoodItemList extends StatelessWidget
{
  //========================================================================
  //Fields
  //========================================================================
  final List<FoodItem> items;
  final IconData fallbackIcon;
  final Color? fallbackColor;

  // ========================================================================
  //Constructor
  //========================================================================
  const FoodItemList(
      {
        super.key,
        required this.items,
        this.fallbackIcon = Icons.fastfood_rounded,
        this.fallbackColor = Colors.black,
      });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints)
            {
              final width = constraints.maxWidth;
              final shouldUseGrid = width >= 700 && items.length > 1;

              if(shouldUseGrid)
                {
                  final crossAxisCount = width >= 1100 ? 3 : 2;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 450,
                    ),
                    itemBuilder: (context, index)
                    {
                      return _FoodItemSurface(
                        child: FoodItemCard(
                          foodItem: items[index],
                          fallbackIcon: fallbackIcon,
                          fallbackColor: fallbackColor,
                          compact: true,
                        ),
                      );
                    },
                  );
                }

              return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 24,),
                itemBuilder: (context, index) {
                  return _FoodItemSurface(
                    child: FoodItemCard(
                      foodItem: items[index],
                      fallbackIcon: fallbackIcon,
                      fallbackColor: fallbackColor,
                    ),
                  );
                },
              );
            }
    );
  }
}

class _FoodItemSurface extends StatelessWidget {
  const _FoodItemSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

