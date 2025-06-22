import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/favorites_manager.dart';
import '../screens/recipe_detail_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesManager>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites'), centerTitle: true),
      body:
          favorites.isEmpty
              ? const Center(child: Text('Belum ada resep yang disukai!'))
              : ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final meal = favorites[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          meal.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        meal.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context.read<FavoritesManager>().removeFavorite(
                            meal.id,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${meal.title} dihapus dari favorit!',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailPage(mealId: meal.id),
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
