import 'dart:convert';
import 'dart:io'; // important
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

import '../Model/addMeal_Model.dart';
class FoodApiService {
  final String _baseUrl = dotenv.env['BASE_URL']!;
  final String _apiKey = dotenv.env['USDA_API_KEY']!;
  Future<List<FoodModel>> searchFood(String query) async {
    final url = Uri.parse(
        "$_baseUrl/foods/search?query=$query&api_key=$_apiKey");

    try {
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List foods = data['foods'] ?? [];
        return foods
            .map((item) => FoodModel.fromUSDAJson(item))
            .toList();
      } else {
        throw Exception("Server error (${response.statusCode})");
      }

    } on SocketException {
      throw Exception("Error: No internet connection");
    } on TimeoutException {
      throw Exception("Request timed out");
    } catch (e) {
      throw Exception("Something went wrong");
    }
  }
}
class FoodServiceBarcode {
  static Future<FoodModel?> fetchFoodByBarcode(String barcode) async {
    final url =
        "https://world.openfoodfacts.org/api/v0/product/$barcode.json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 1) {
          return FoodModel.fromBarcodeJson(data['product'],100);
        } else {
          print("Product not found");
          return null;
        }
      } else {
        print("API error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }}