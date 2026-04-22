import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import 'package:firebase_database/firebase_database.dart';
class homeprovider extends ChangeNotifier {
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ───────────────── DATE ─────────────────
  DateTime selectedDate = DateTime.now();

  void setDate(DateTime date) {
    selectedDate = date;
    final user = FirebaseAuth.instance.currentUser;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    listenToTotals(user!.uid, formattedDate);
    notifyListeners();
  }

  String getDateText() {
    DateTime today = DateTime.now();

    if (selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day) {
      return "Today";
    }

    return DateFormat('d-MMM').format(selectedDate);
  }

  // ───────────────── User target Credential ─────────────────
  //used -> home screen to show target,Drawer screen and also profile details
  int caltarget = 0;
  int carbstarget = 0;
  int fattarget = 0;
  int proteintarget = 0;
  String Name = "";
  String url="";
  String goal="";
  String gender="";
  int weight=0;
  int height=0;
  String diteType="";
  int age=0;


  Future<void> fetchTargets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseDatabase.instance
        .ref("users/${user.uid}/profile")
        .get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      caltarget = (data['calories'] ?? 0);
      proteintarget = (data['protein'] ?? 0);
      fattarget = (data['fat'] ?? 0);
      carbstarget = (data['carbs'] ?? 0);
      Name = data['name']?.toString() ?? "Guest";
      url=data['photoUrl'];
      goal=data['goal'];
      gender=data['gender'];
      height=data['height'];
      diteType=data['dietType'];
      age=data['age'];
      weight=data['weight'];
      notifyListeners();
    }
  }

  // ────────────────Calculate Totals User intake daily Nutrition ─────────────────

  double calories = 0;
  double protein = 0;
  double fat = 0;
  double carbs = 0;

  void listenToTotals(String uid, String date) {
    _subscription?.cancel();

    List<String> meals = ['breakfast', 'lunch', 'dinner', 'snacks'];

    final baseRef = FirebaseFirestore.instance
        .collection('addfood')
        .doc(uid)
        .collection('meals')
        .doc(date);

    final streams =
    meals.map((meal) => baseRef.collection(meal).snapshots()).toList();

    final mergedStream = StreamGroup.merge(streams);

    _subscription = mergedStream.listen((_) async {
      double cal = 0, pro = 0, f = 0, carb = 0;

      for (String meal in meals) {
        var snapshot = await baseRef.collection(meal).get();

        for (var doc in snapshot.docs) {
          var item = doc.data();

          cal += (item['calories'] ?? 0);
          pro += (item['protein'] ?? 0);
          f += (item['fat'] ?? 0);
          carb += (item['carbs'] ?? 0);
        }
      }

      calories = cal;
      protein = pro;
      fat = f;
      carbs = carb;

      notifyListeners();
    });
  }
  //----------------Update profile------------------//
  void updateAllFields(Map<String, String> data) {
    try {
      // 🔹 Basic fields
      Name = data["Name"] ?? Name;
      gender = data["Gender"] ?? gender;
      diteType = data["Diet Type"] ?? diteType;
      goal = data["Goal"] ?? goal;

      // 🔹 Numeric fields (safe parsing)
      age = int.tryParse(data["Age"] ?? "") ?? age;
      caltarget = int.tryParse(data["Targeted cal"] ?? "") ?? caltarget;
      proteintarget =
          int.tryParse(data["Targeted Protein"] ?? "") ?? proteintarget;
      carbstarget =
          int.tryParse(data["Targeted Carbs"] ?? "") ?? carbstarget;
      fattarget = int.tryParse(data["Targeted Fat"] ?? "") ?? fattarget;

      // 🔹 Notify UI
      notifyListeners();

      // 🔹 TODO: Save to Firebase / API
      saveToRealtimeDB();
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }


  //--------User Edit own Profile data and save on Firebase-------
  Future<void> saveToRealtimeDB() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint("User not logged in");
        return;
      }

      await FirebaseDatabase.instance
          .ref("users/${user.uid}/profile")
          .set({
        "name": Name,
        "age": age,
        "gender": gender,
        "dietType": diteType,
        "goal": goal,
        "calories": caltarget,
        "protein": proteintarget,
        "carbs": carbstarget,
        "fat": fattarget,
        "photoUrl": url,
        "weight":weight,
        "height":height,
        "profileCompleted":true,
      });

      debugPrint("Data saved successfully");

    } catch (e) {
      debugPrint("Error saving data: $e");
    }
  }



}