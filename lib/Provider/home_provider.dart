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

  // ───────────────── TARGETS ─────────────────
  int caltarget = 0;
  int carbstarget = 0;
  int fattarget = 0;
  int proteintarget = 0;
  String Name = "";
  String url="";

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
      notifyListeners();
    }
  }

  // ───────────────── TOTALS ─────────────────
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



}