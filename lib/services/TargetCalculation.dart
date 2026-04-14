import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
Map<String, dynamic> calculateMacros({
  required double weight,
  required double height,
  required int age,
  required String gender,
  required String goal,
}) {
  double bmr;

  if (gender == "Male") {
    bmr = 10 * weight + 6.25 * height - 5 * age + 5;
  } else {
    bmr = 10 * weight + 6.25 * height - 5 * age - 161;
  }

  double tdee = bmr * 1.55;

  if (goal == "Lose weight") {
    tdee -= 400;
  } else if (goal == "Build muscle") {
    tdee += 400;
  }
  // "Stay in shape" → no adjustment

  double protein = weight * 2;
  double fat = (tdee * 0.25) / 9;
  double carbs = (tdee - (protein * 4 + fat * 9)) / 4;

  return {
    "calories": tdee.round(),
    "protein": protein.round(),
    "fat": fat.round(),
    "carbs": carbs.round(),
  };
}Future<void> saveTargetsToFirebase(Map<String, dynamic> data) async {
  final user = FirebaseAuth.instance.currentUser;
  final uid = user!.uid;

  await FirebaseDatabase.instance
      .ref("users/$uid/profile")
      .update(data);
}