import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../managers/favorites_manager.dart';

class RecipeDetailPage extends StatefulWidget {
  final String mealId;
  const RecipeDetailPage({super.key, required this.mealId});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  String imageUrl = '';
  String title = '';
  String duration = '60 mins';
  String servings = '4';
  List<String> ingredients = [];
  List<String> steps = [];
  List<bool> _isChecked = [];
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    fetchMealDetails();
  }

  Future<void> fetchMealDetails() async {
    final url =
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.mealId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meal = data['meals'][0];

      final favManager = Provider.of<FavoritesManager>(context, listen: false);

      setState(() {
        title = meal['strMeal'] ?? '';
        imageUrl = meal['strMealThumb'] ?? '';
        ingredients =
            List.generate(20, (i) {
              final ingredient = meal['strIngredient${i + 1}'];
              final measure = meal['strMeasure${i + 1}'];
              if ((ingredient != null &&
                      ingredient.toString().trim().isNotEmpty) &&
                  (measure != null && measure.toString().trim().isNotEmpty)) {
                return '$measure $ingredient';
              }
              return '';
            }).where((e) => e.isNotEmpty).toList();

        steps =
            meal['strInstructions']
                .toString()
                .split(RegExp(r'(?<=[.!?])\s+(?=[A-Z])'))
                .where((s) => s.trim().isNotEmpty)
                .map((s) => s.trim())
                .toList();

        _isChecked = List<bool>.filled(ingredients.length, false);
        servings = meal['strArea'] ?? '4';

        // cek favorit dari provider
        isFavorite = favManager.isFavorite(widget.mealId);
        isLoading = false;
      });
    }
  }

  void toggleFavorite() {
    final favManager = Provider.of<FavoritesManager>(context, listen: false);
    setState(() {
      isFavorite = !isFavorite;
      if (isFavorite) {
        favManager.addFavorite(widget.mealId, title, imageUrl);
      } else {
        favManager.removeFavorite(widget.mealId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // Background Image
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Image.network(
                      imageUrl,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Scrollable Content
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 220),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(50),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: AppTextStyles.sectionTitle),
                                const SizedBox(height: 4),
                                Text(
                                  "Food · $duration",
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Ingredients:',
                                  style: AppTextStyles.sectionTitle,
                                ),
                                const SizedBox(height: 12),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: ingredients.length,
                                  itemBuilder: (context, index) {
                                    return CheckboxListTile(
                                      title: Text(ingredients[index]),
                                      value: _isChecked[index],
                                      onChanged: (val) {
                                        setState(
                                          () => _isChecked[index] = val!,
                                        );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Instructions:',
                                  style: AppTextStyles.sectionTitle,
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  children: List.generate(steps.length, (
                                    index,
                                  ) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundColor: AppColors.primary,
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(child: Text(steps[index])),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top Buttons
                  Positioned(
                    top: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: toggleFavorite,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
