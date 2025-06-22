class Meal {
  final String id;
  final String name;
  final String thumbnail;
  final String instructions;
  final List<String> ingredients;

  Meal({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.instructions,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null &&
          ingredient.toString().isNotEmpty &&
          ingredient.toString().trim() != '') {
        final formatted = (measure ?? '').toString().trim().isNotEmpty
            ? '${measure.toString().trim()} ${ingredient.toString().trim()}'
            : ingredient.toString().trim();
        ingredients.add(formatted);
      }
    }

    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      thumbnail: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
      ingredients: ingredients,
    );
  }
}
