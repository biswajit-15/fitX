// class FoodModel {
//   final String description;
//   final double? calories;
//   final double? protein;
//   final double? carbs;
//   final double? fat;
//   final double? servingSize;
//   final String? unit;
//
//   FoodModel({
//     required this.description,
//     this.calories,
//     this.protein,
//     this.carbs,
//     this.fat,
//     this.servingSize,
//     this.unit,
//   });
//
//   factory FoodModel.fromJson(Map<String, dynamic> json) {
//     double protein = 0;
//     double carbs = 0;
//     double fat = 0;
//     double calories = 0;
//
//     final nutrients = json['foodNutrients'] as List<dynamic>?;
//
//     if (nutrients != null) {
//       for (var n in nutrients) {
//         final name = n['nutrientName'];
//         final value = (n['value'] ?? 0).toDouble();
//
//         if (name == "Energy") {
//           calories = value;
//         } else if (name == "Protein") {
//           protein = value;
//         } else if (name == "Carbohydrate, by difference") {
//           carbs = value;
//         } else if (name == "Total lipid (fat)") {
//           fat = value;
//         }
//       }
//     }
//
//     return FoodModel(
//       description: json['description'] ?? '',
//       calories: calories,
//       protein: protein,
//       carbs: carbs,
//       fat: fat,
//       servingSize: (json['servingSize'] ?? 100).toDouble(),
//       unit: json['servingSizeUnit'],
//     );
//   }
// }
class FoodModel {
  final String description;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? servingSize;
  final String? unit;

  FoodModel({
    required this.description,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.servingSize,
    this.unit,
  });

  /// 🔹 USDA / Search / Manual Entry
  factory FoodModel.fromUSDAJson(Map<String, dynamic> json) {
    double protein = 0, carbs = 0, fat = 0, calories = 0;

    final nutrients = json['foodNutrients'] as List<dynamic>?;

    if (nutrients != null) {
      for (var n in nutrients) {
        final name = n['nutrientName'];
        final value = (n['value'] ?? 0).toDouble();

        if (name == "Energy") {
          calories = value;
        } else if (name == "Protein") {
          protein = value;
        } else if (name == "Carbohydrate, by difference") {
          carbs = value;
        } else if (name == "Total lipid (fat)") {
          fat = value;
        }
      }
    }

    return FoodModel(
      description: json['description'] ?? '',
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      servingSize: (json['servingSize'] ?? 100).toDouble(),
      unit: json['servingSizeUnit'],
    );
  }

  factory FoodModel.fromBarcodeJson(Map<String, dynamic> json,double quantity) {
    final nutriments = json['nutriments'] ?? {};


    double factor;


      factor =  quantity/ 100;


    return FoodModel(
      description: json['product_name'] ?? "Unknown Product",
      calories: (nutriments['energy-kcal_100g'] ?? 0).toDouble() * factor,
      protein: (nutriments['proteins_100g'] ?? 0).toDouble() * factor,
      carbs: (nutriments['carbohydrates_100g'] ?? 0).toDouble() * factor,
      fat: (nutriments['fat_100g'] ?? 0).toDouble() * factor,
      servingSize: quantity,
    );
  }
}
