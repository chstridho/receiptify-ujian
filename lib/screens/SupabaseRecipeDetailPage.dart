import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SupabaseRecipeDetailPage extends StatefulWidget {
  final int recipeId;

  const SupabaseRecipeDetailPage({super.key, required this.recipeId});

  @override
  State<SupabaseRecipeDetailPage> createState() => _SupabaseRecipeDetailPageState();
}

class _SupabaseRecipeDetailPageState extends State<SupabaseRecipeDetailPage> {
  String title = '';
  String imageUrl = '';
  String stepImageUrl = '';
  List<String> ingredients = [];
  List<String> steps = [];
  List<bool> _isChecked = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchRecipeFromSupabase();
  }

  Future<void> fetchRecipeFromSupabase() async {
    final supabase = Supabase.instance.client;

    try {
      final res = await supabase
          .from('recipes')
          .select()
          .eq('id', widget.recipeId)
          .single();

      print('Fetched recipe data: $res');

      setState(() {
        title = res['food_name'] ?? '';
        imageUrl = res['cover_url'] ?? '';
        stepImageUrl = res['step_image_url'] ?? '';

        ingredients = List<String>.from(res['ingredients'] ?? []);
        steps = (res['steps'] ?? '')
            .toString()
            .split('\n')
            .where((s) => s.trim().isNotEmpty)
            .toList();
        _isChecked = List<bool>.filled(ingredients.length, false);
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      print('Error fetching recipe: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      const Text('Failed to load recipe.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: fetchRecipeFromSupabase,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
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
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.broken_image, size: 60)),
                        ),
                      ),
                    ),

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
                                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: AppTextStyles.sectionTitle),
                                  const SizedBox(height: 16),
                                  const Text('Ingredients:', style: AppTextStyles.sectionTitle),
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
                                          setState(() {
                                            _isChecked[index] = val ?? false;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  const Text('Instructions:', style: AppTextStyles.sectionTitle),
                                  const SizedBox(height: 12),
                                  Column(
                                    children: List.generate(steps.length, (index) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundColor: AppColors.primary,
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(child: Text(steps[index])),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),

                                  // Step image
                                  if (stepImageUrl.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          stepImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Back button
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
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
