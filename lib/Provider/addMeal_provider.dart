import 'package:flutter/cupertino.dart';
import '../Model/addMeal_Model.dart';
import '../services/addmealService.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Addmeal with ChangeNotifier {
  String _selectedMeal = "Breakfast";

  List<FoodModel> searchResults = [];
  bool isLoading = false;
  String errorMessage = '';
  String searchQuery = '';

  String get selectedMeal => _selectedMeal;

  List<String> meals = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Snacks"
  ];

  void changeMeal(String meal) {
    _selectedMeal = meal;
    notifyListeners();
  }

  // 🔍 SEARCH FOOD (move here)
  Future<void> searchFood(String query) async {
    searchQuery = query;
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      searchResults = await FoodApiService().searchFood(query);
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // ❌ CLEAR SEARCH
  void clearSearch() {
    searchQuery = '';
    searchResults.clear();
    errorMessage = '';
    isLoading = false;
    notifyListeners();
  }
  Future<void> addfood({
    required String userid,
    required DateTime selectedDate,
    required int gram,
    FoodModel? food,          // ← make optional
    String? foodName,
    double? manualCalories,
    double? manualProtein,
    double? manualFat,
    double? manualCarbs,
  }) async {
    try {
      final date = DateFormat('yyyy-MM-dd').format(selectedDate);

      Map<String, dynamic> data;

      if (food != null) {
        // ─── Normal food search add ───────────────────────────
        final servingSize = (food.servingSize == null || food.servingSize! == 0)
            ? 100.0
            : food.servingSize!;
        final factor = gram / servingSize;

        data = {
          "name": food.description,
          "calories": (food.calories ?? 0) * factor,
          "protein": (food.protein ?? 0) * factor,
          "carbs": (food.carbs ?? 0) * factor,
          "fat": (food.fat ?? 0) * factor,
          "grams": gram,
          "mealType": _selectedMeal.toLowerCase(),
          "timestamp": FieldValue.serverTimestamp(),
          "isManual": false,
        };
      } else {
        // ─── Manual add ───────────────────────────────────────
        data = {
          "name": foodName ?? "Unknown",
          "calories": manualCalories ?? 0,
          "protein": manualProtein ?? 0,
          "carbs": manualCarbs ?? 0,
          "fat": manualFat ?? 0,
          "grams": gram,
          "mealType": _selectedMeal.toLowerCase(),
          "timestamp": FieldValue.serverTimestamp(),
          "isManual": true,
        };
      }

      await FirebaseFirestore.instance
          .collection('addfood')
          .doc(userid)
          .collection('meals')
          .doc(date)
          .collection(_selectedMeal.toLowerCase())
          .add(data);

    } catch (e) {
      errorMessage = e.toString();
      print("Error adding food: $e");
      notifyListeners();
    }
  }
}