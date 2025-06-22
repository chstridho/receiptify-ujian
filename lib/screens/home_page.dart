import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receiptify/screens/SupabaseRecipeDetailPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receiptify/screens/see_all_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/featured_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/popular_recipe_card.dart';
import '../screens/recipe_detail_page.dart';
import '../screens/favorite_page.dart';
import '../screens/profile_page.dart';
import '../screens/sign_in_page.dart';
import '../services/meal_api.dart';
import '../screens/upload_recipe/upload_part1.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int selectedCategoryIndex = 0;
  final TextEditingController _searchQueryController = TextEditingController();
  bool isSearching = false;

  List<dynamic> recipes = [];
  List<dynamic> supabaseSearchResults = [];
  bool isLoading = true;
  String? userName;

  @override
  void initState() {
    super.initState();
    final api = context.read<MealApi>();

    api.loadFeatured();
    api.loadCategories().then((_) {
      if (api.categories.isNotEmpty) {
        setState(() {
          selectedCategoryIndex = 0;
        });
        api.loadPopular(api.categories[0]);
      }
    });

    loadRecipes();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final data = await supabase
            .from('users')
            .select('name')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            userName = data['name'] ?? 'User';
          });
        }
      } catch (e) {
        print('Failed to fetch user name: $e');
        if (mounted) {
          setState(() {
            userName = 'User';
          });
        }
      }
    }
  }

  Future<void> loadRecipes() async {
    final supabase = Supabase.instance.client;

    try {
      final data = await supabase
          .from('recipes')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        recipes = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching recipes: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchSupabaseRecipes(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      supabaseSearchResults = recipes.where((r) {
        final name = (r['food_name'] ?? '').toLowerCase();
        return name.contains(lowerQuery);
      }).toList();
    });
  }

  Widget buildHomeContent(BuildContext context) {
    final api = context.watch<MealApi>();
    final screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: loadRecipes,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          screenWidth < 600 ? 16 : 29,
          screenWidth < 600 ? 48 : 87,
          screenWidth < 600 ? 16 : 29,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.fastfood, size: 24, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Good Morning', style: AppTextStyles.greeting),
                  ],
                ),
              ],
            ),
            userName == null
                ? const CircularProgressIndicator()
                : Text('$userName!', style: AppTextStyles.userName),

            const SizedBox(height: 24),

            TextField(
              controller: _searchQueryController,
              onChanged: (query) {
                setState(() {
                  isSearching = query.isNotEmpty;
                });

                if (query.isNotEmpty) {
                  api.searchMeals(query);
                  searchSupabaseRecipes(query);
                } else {
                  if (api.categories.isNotEmpty) {
                    api.loadPopular(api.categories[selectedCategoryIndex]);
                  }
                  supabaseSearchResults = [];
                }
              },
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchQueryController.clear();
                          setState(() {
                            isSearching = false;
                          });
                          if (api.categories.isNotEmpty) {
                            api.loadPopular(api.categories[selectedCategoryIndex]);
                          }
                          supabaseSearchResults = [];
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 33),
            const Text('Featured', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 14),

            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: api.featured.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: FeaturedCard(
                      imageUrl: m.thumbnail,
                      title: m.name,
                      chef: 'Chef',
                      duration: '20 Min',
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
                }).toList(),
              ),
            ),

            const SizedBox(height: 25),

            if (!isSearching) ...[
              // Category Section with See All
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Category', style: AppTextStyles.sectionTitle),
                  GestureDetector(
                    onTap: () {
                      // Navigate to SeeAllPage for all categories or popular meals in categories
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeeAllPage(
                            title: 'All Categories',
                            meals: api.popular, // You can adjust if you want to show something else here
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'See All',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: api.categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: CategorySelector(
                        categories: [category],
                        selectedIndex: index == selectedCategoryIndex ? 0 : -1,
                        onCategorySelected: (idx) {
                          if (idx == 0 && index < api.categories.length) {
                            setState(() {
                              selectedCategoryIndex = index;
                            });
                            api.loadPopular(api.categories[index]);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 25),

              // Popular Recipes Section with See All
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Popular Recipes', style: AppTextStyles.sectionTitle),
                  GestureDetector(
                    onTap: () {
                      // Navigate to SeeAllPage for popular recipes
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeeAllPage(
                            title: 'Popular Recipes',
                            meals: api.popular,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'See All',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Column(
                children: api.popular.map((m) {
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
                }).toList(),
              ),
            ] else ...[
              // Search Results Section
              const Text('Search Results', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 14),
              Column(
                children: [
                  ...api.searchResults.map((m) => Padding(
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
                      )),
                  ...supabaseSearchResults.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: PopularRecipeCard(
                          imageUrl: r['cover_url'] ?? '',
                          title: r['food_name'] ?? '',
                          calories: '– Kcal',
                          duration: '– Min',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SupabaseRecipeDetailPage(recipeId: r['id']),
                              ),
                            );
                          },
                        ),
                      )),
                ],
              ),
            ],

            const SizedBox(height: 25),

            if (!isSearching) ...[
              // Latest User Recipes (Langsung tampil di HomePage)
              const Text('Latest User Recipes', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 14),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: recipes.map((r) {
                        final imageUrl = r['cover_url'] ?? '';
                        final title = r['food_name'] ?? '';
                        final calories = '–';
                        final duration = '–';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: PopularRecipeCard(
                            imageUrl: imageUrl,
                            title: title,
                            calories: '$calories Kcal',
                            duration: '$duration Min',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SupabaseRecipeDetailPage(
                                    recipeId: r['id'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            buildHomeContent(context),
            const UploadStep1(),
            const FavoritePage(),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
