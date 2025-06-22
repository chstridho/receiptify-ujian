import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealApi extends ChangeNotifier {
  List<Meal> _featured = [];
  List<String> _categories = [];

  List<Meal> get featured => _featured;
  List<String> get categories => _categories;

  Future<void> loadFeatured() async {
    final resp = await http.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=a'),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      _featured = (data['meals'] as List).map((j) => Meal.fromJson(j)).toList();
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    final resp = await http.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?c=list'),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      _categories =
          (data['meals'] as List)
              .map((j) => j['strCategory'] as String)
              .toList();
      notifyListeners();
    }
  }

  Future<void> loadPopular(String category) async {
    final resp = await http.get(
      Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category',
      ),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      _popular = (data['meals'] as List).map((j) => Meal.fromJson(j)).toList();
      notifyListeners();
    }
  }

  List<Meal> _popular = [];
  List<Meal> get popular => _popular;

  List<Meal> _searchResults = [];
List<Meal> get searchResults => _searchResults;

Future<void> searchMeals(String query) async {
  final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$query'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['meals'] != null) {
      _searchResults = (data['meals'] as List).map((meal) => Meal.fromJson(meal)).toList();
    } else {
      _searchResults = [];
    }
    notifyListeners();
  } else {
    throw Exception('Failed to search meals');
  }
}

}
