import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/popular_recipe_card.dart';
import '../models/meal.dart';
import 'recipe_detail_page.dart';

class SeeAllPage extends StatelessWidget {
  final String title;
  final List<Meal> meals;

  const SeeAllPage({
    super.key,
    required this.title,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: meals.length,
        itemBuilder: (ctx, i) {
          final m = meals[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: PopularRecipeCard(
              imageUrl: m.thumbnail,
              title: m.name,
              calories: '– Kcal',
              duration: '– Min',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailPage(mealId: m.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
