// import 'package:flutter/material.dart';
// import '../services/addmealService.dart';
//
// class AddMealViewModel extends ChangeNotifier {
//   final FoodApiService _apiService = FoodApiService();
//
//   List<dynamic> searchResults = [];
//   bool isLoading = false;
//   String errorMessage = '';
//
//   Future<void> searchFood(String query) async {
//     if (query.trim().isEmpty) return;
//
//     isLoading = true;
//     errorMessage = '';
//     notifyListeners();
//
//     try {
//       final rawResults = await _apiService.searchFood(query);
//
//       // 🔥 CLEAN + FILTER HERE
//       searchResults = _cleanResults(rawResults);
//
//     } catch (e) {
//       errorMessage = e.toString();
//     }
//
//     isLoading = false;
//     notifyListeners();
//   }
// }
// List<dynamic> _cleanResults(List<dynamic> foods) {
//   final unique = <String, dynamic>{};
//
//   for (var food in foods) {
//     final name = (food['description'] ?? '').toLowerCase();
//
//     // ❌ remove empty
//     if (name.isEmpty) continue;
//
//     // ❌ remove very long / confusing names
//     if (name.length > 50) continue;
//
//     // ❌ remove duplicates
//     if (!unique.containsKey(name)) {
//       unique[name] = food;
//     }
//   }
//
//   final list = unique.values.toList();
//
//   // ✅ sort by short name (better UX)
//   list.sort((a, b) {
//     return (a['description'] ?? '')
//         .length
//         .compareTo((b['description'] ?? '').length);
//   });
//
//   // ✅ limit results
//   return list.take(15).toList();
// }