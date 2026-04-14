import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class DayLog {
  final DateTime date;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  DayLog({
    required this.date,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

typedef MacroRecord = ({
double calories,
double protein,
double fat,
double carbs,
});

class HistoryProvider extends ChangeNotifier {
  int weekOffset = 0;

  late DateTime startOfWeek;
  late DateTime endOfWeek;

  List<DayLog> weekLogs = [];
  bool isLoading = false;
  String? error;

  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  // Hold all active stream subscriptions so we can cancel on week change
  final List<StreamSubscription> _subs = [];

  HistoryProvider() {
    loadCurrentWeek();
  }

  @override
  void dispose() {
    _cancelSubs();
    super.dispose();
  }

  void _cancelSubs() {
    for (final s in _subs) s.cancel();
    _subs.clear();
  }

  // ── Week calculation ───────────────────────────────────────────────────────

  void calculateWeek() {
    final now    = _stripTime(DateTime.now());
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final targetMonday = monday.add(Duration(days: weekOffset * 7));

    startOfWeek = targetMonday;
    endOfWeek   = targetMonday.add(const Duration(days: 6));
  }

  void loadCurrentWeek() {
    weekOffset = 0;
    calculateWeek();
    _listenWeekLogs();
  }

  void previousWeek() {
    weekOffset--;
    calculateWeek();
    _listenWeekLogs();
  }

  void nextWeek() {
    if (weekOffset >= 0) return;
    weekOffset++;
    calculateWeek();
    _listenWeekLogs();
  }

  // ── Real-time listener (parallel fetches for all 7 days) ──────────────────

  void _listenWeekLogs() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Cancel previous week's listeners
    _cancelSubs();

    isLoading = true;
    error     = null;
    weekLogs  = [];
    notifyListeners();

    const meals = ['breakfast', 'lunch', 'dinner'];

    // Map to collect latest data per day index
    final Map<int, DayLog?> dayMap = {};

    for (int i = 0; i < 7; i++) {
      final date    = startOfWeek.add(Duration(days: i));
      final dateStr = _formatDateKey(date);
      final dayIndex = i;

      final baseRef = _db
          .collection('addfood')
          .doc(uid)
          .collection('meals')
          .doc(dateStr);

      // Listen to all 3 meal collections simultaneously using StreamZip logic
      // We merge them by listening to each and recomputing the day total
      final Map<String, List<Map<String, dynamic>>> mealCache = {
        'breakfast': [],
        'lunch': [],
        'dinner': [],
      };

      for (final meal in meals) {
        final sub = baseRef.collection(meal).snapshots().listen(
              (snapshot) {
            // Update this meal's cache
            mealCache[meal] = snapshot.docs.map((d) => d.data()).toList();

            // Recompute day total from all 3 meals
            double cal = 0, pro = 0, f = 0, carb = 0;
            bool hasData = false;

            for (final items in mealCache.values) {
              for (final item in items) {
                cal  += (item['calories'] ?? 0).toDouble();
                pro  += (item['protein']  ?? 0).toDouble();
                f    += (item['fat']      ?? 0).toDouble();
                carb += (item['carbs']    ?? 0).toDouble();
                hasData = true;
              }
            }

            dayMap[dayIndex] = hasData
                ? DayLog(date: date, calories: cal, protein: pro, fat: f, carbs: carb)
                : null;

            // Rebuild weekLogs from dayMap
            weekLogs = List.generate(7, (idx) => dayMap[idx])
                .whereType<DayLog>()
                .toList();

            isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            error     = e.toString();
            isLoading = false;
            notifyListeners();
          },
        );

        _subs.add(sub);
      }
    }
  }

  // Keep fetchWeekLogs as a public alias in case UI calls it (e.g. retry button)
  Future<void> fetchWeekLogs() async => _listenWeekLogs();

  // ── Full 7-slot list ───────────────────────────────────────────────────────

  List<({DateTime date, DayLog? log})> get currentWeekDays {
    return List.generate(7, (i) {
      final date = startOfWeek.add(Duration(days: i));
      final log  = weekLogs.where((l) => _stripTime(l.date) == date).firstOrNull;
      return (date: date, log: log);
    });
  }

  // ── Totals & Averages ──────────────────────────────────────────────────────

  MacroRecord get weekTotals => (
  calories: weekLogs.fold(0, (s, l) => s + l.calories),
  protein:  weekLogs.fold(0, (s, l) => s + l.protein),
  fat:      weekLogs.fold(0, (s, l) => s + l.fat),
  carbs:    weekLogs.fold(0, (s, l) => s + l.carbs),
  );

  MacroRecord get weekAverages {
    final t = weekTotals;
    return (
    calories: t.calories / 7,
    protein:  t.protein  / 7,
    fat:      t.fat      / 7,
    carbs:    t.carbs    / 7,
    );
  }

  String get formattedRange =>
      "${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}";

  // ── Helpers ────────────────────────────────────────────────────────────────

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  String _formatDateKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDate(DateTime date) =>
      "${date.day} ${_monthName(date.month)}";

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }
}