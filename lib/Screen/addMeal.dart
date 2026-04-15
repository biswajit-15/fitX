import 'package:fitx/Provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/addMeal_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/addmealService.dart';
import '../widgets/globalUiHelper.dart';
import 'barcodescan.dart';

class AddMeal extends StatefulWidget {
  const AddMeal({super.key});

  @override
  State<AddMeal> createState() => _AddMealState();
}

class _AddMealState extends State<AddMeal> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0A0F1C);
  static const _surface = Color(0xFF131B2E);
  static const _card = Color(0xFF1C2640);
  static const _accent = Color(0xFF4F8EF7);
  static const _accentGlow = Color(0x334F8EF7);
  static const _green = Color(0xFF2ECC8A);
  static const _textPrimary = Color(0xFFE8EDF5);
  static const _textSecondary = Color(0xFF7A8BAA);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Meal icon map ───────────────────────────────────────────────────────────
  IconData _mealIcon(String meal) {
    switch (meal.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.wb_cloudy_outlined;
      case 'dinner':
        return Icons.nightlight_round;
      case 'snacks':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  // ── Add food dialog ─────────────────────────────────────────────────────────
  void _showAddDialog(BuildContext context, dynamic food) {
    final gramController = TextEditingController(text: '100');
    double servingSize = (food.servingSize ?? 0).toDouble();
    double calories = food.calories ?? 0;
    if (servingSize == 0) servingSize = 100;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          StatefulBuilder(
            builder: (ctx, setS) {
              final grams = double.tryParse(gramController.text) ?? 100;
              final kcal = (calories / servingSize) * grams;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery
                      .of(ctx)
                      .viewInsets
                      .bottom,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: _textSecondary.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Food name
                      Text(
                        food.description ?? '',
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${servingSize.toStringAsFixed(0)} g per serving",
                        style: const TextStyle(
                            color: _textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // Live calorie preview
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _accentGlow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Estimated calories",
                                style: TextStyle(
                                    color: _textSecondary, fontSize: 13)),
                            Text(
                              "${kcal.toStringAsFixed(0)} kcal",
                              style: const TextStyle(
                                color: _accent,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Grams field
                      Text("Quantity (grams)",
                          style: TextStyle(color: _textSecondary, fontSize: 12,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: gramController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            color: _textPrimary, fontSize: 16),
                        onChanged: (_) => setS(() {}),
                        decoration: InputDecoration(
                          hintText: "e.g. 150",
                          hintStyle: const TextStyle(color: _textSecondary),
                          filled: true,
                          fillColor: _card,
                          suffixText: "g",
                          suffixStyle: const TextStyle(color: _textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _accent,
                                width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      color: _textSecondary.withOpacity(0.3)),
                                ),
                              ),
                              child: const Text("Cancel",
                                  style: TextStyle(
                                      color: _textSecondary, fontSize: 15)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                final grams = int.tryParse(
                                    gramController.text) ?? 0;
                                if (grams <= 0) return;
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) return;
                                final home = Provider.of<homeprovider>(
                                    context, listen: false);
                                await context.read<Addmeal>().addfood(
                                  userid: user.uid,
                                  food: food,
                                  gram: grams,
                                  selectedDate: home.selectedDate,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Add to Meal",
                                  style: TextStyle(fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<Addmeal>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(context, vm),
          Expanded(child: _buildBody(context, vm)),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      centerTitle: true,
      title: Consumer<Addmeal>(
        builder: (context, mealProvider, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: mealProvider.selectedMeal,
                icon: const Icon(Icons.expand_more_rounded,
                    color: _accent, size: 20),
                dropdownColor: _card,
                isDense: true,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                onChanged: (value) => mealProvider.changeMeal(value!),
                items: mealProvider.meals.map((meal) {
                  return DropdownMenuItem(
                    value: meal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_mealIcon(meal), size: 16, color: _accent),
                        const SizedBox(width: 8),
                        Text(meal),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, Addmeal vm) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: _textPrimary, fontSize: 15),
        decoration: InputDecoration(
          filled: true,
          fillColor: _card,
          hintText: "Search for food...",
          hintStyle: const TextStyle(color: _textSecondary, fontSize: 15),
          prefixIcon: const Icon(Icons.search_rounded, color: _accent),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close_rounded,
                color: _textSecondary, size: 20),
            onPressed: () {
              _searchController.clear();
              vm.clearSearch();
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onSubmitted: (value) {
          if (value
              .trim()
              .isNotEmpty) vm.searchFood(value);
        },
        textInputAction: TextInputAction.search,
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, Addmeal vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _accent, strokeWidth: 2.5),
      );
    }

    if (vm.errorMessage.isNotEmpty) {
      return _buildErrorState(vm);
    }

    if (vm.searchResults.isEmpty) {
      return _buildEmptyState();
    }

    _fadeController
      ..reset()
      ..forward();
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: vm.searchResults.length,
        itemBuilder: (context, index) =>
            _buildFoodCard(context, vm.searchResults[index], index),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        //  mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add Meal Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _showManualAddDialog(context);
                        },
                        icon: const Icon(
                            Icons.add, size: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),//ssll
                    const Text(

                      "Manual Add",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ScanScreen()),
                          );

                          if (result != null) {
                            print("Barcode: $result");

                            final food = await FoodServiceBarcode.fetchFoodByBarcode(result);

                            if (food != null) {
                              print("Name: ${food.description}");
                              print("Calories: ${food.calories}");
                              print("protein: ${food.protein}");
                              print("fat: ${food.fat}");
                              print("Carbs: ${food.carbs}");
                              print("quantity: ${food.servingSize}");


                            } else {
                              print("No data found");
                            }
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner, size: 50,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Barcode Scan",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Search hint
          Icon(Icons.search, size: 64, color: _textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            "Search for food to get started",
            style: TextStyle(color: _textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ── Error state ─────────────────────────────────────────────────────────────
  Widget _buildErrorState(Addmeal vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 52, color: _textSecondary),
            const SizedBox(height: 16),
            Text(vm.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => vm.searchFood(_searchController.text),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Food card ───────────────────────────────────────────────────────────────
  Widget _buildFoodCard(BuildContext context, dynamic food, int index) {
    double calories = food.calories ?? 0;
    double servingSize = (food.servingSize ?? 0).toDouble();
    String unit = food.unit ?? '';
    if (servingSize == 0) {
      servingSize = 100;
      unit = "g";
    }

    // Macro bars (estimated — protein/carbs/fat not always in API)
    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + index * 40),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: _accentGlow,
          onTap: () => _showAddDialog(context, food),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Calorie badge
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: _accentGlow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        calories.toStringAsFixed(0),
                        style: const TextStyle(
                          color: _accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text("kcal",
                          style: TextStyle(
                              color: _accent, fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Name + serving
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "per ${servingSize.toStringAsFixed(0)} $unit",
                        style: const TextStyle(
                            color: _textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Add button
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: _green, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// ─── Alert Dialog ────────────────────────────────────────────────────────────

  void _showManualAddDialog(BuildContext context) {
    final _foodNameController = TextEditingController();
    final _weightController = TextEditingController();
    final _caloriesController = TextEditingController();
    final _proteinController = TextEditingController();
    final _fatController = TextEditingController();
    final _carbsController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _bg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.edit_note, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text(
                "Manual Add Food",
                style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogField(
                    controller: _foodNameController,
                    label: "Food Name",
                    icon: Icons.fastfood,
                    keyboardType: TextInputType.text,
                    validator: (v) => v!.isEmpty ? "Enter food name" : null,
                  ),
                  _buildDialogField(
                    controller: _weightController,
                    label: "Weight (g)",
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Enter weight" : null,
                  ),
                  _buildDialogField(
                    controller: _caloriesController,
                    label: "Calories (kcal)",
                    icon: Icons.local_fire_department_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Enter calories" : null,
                  ),
                  _buildDialogField(
                    controller: _proteinController,
                    label: "Protein (g)",
                    icon: Icons.egg_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Enter protein" : null,
                  ),
                  _buildDialogField(
                    controller: _fatController,
                    label: "Fat (g)",
                    icon: Icons.water_drop_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Enter fat" : null,
                  ),
                  _buildDialogField(
                    controller: _carbsController,
                    label: "Carbs (g)",
                    icon: Icons.grain,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Enter carbs" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final provider = context.read<Addmeal>();
                  final user = FirebaseAuth.instance.currentUser;
                  final home = Provider.of<homeprovider>(
                      context, listen: false);

                  // ─── Null check for user ───────────────────────────────
                  if (user == null) {
                    UiHelper.showToast(context: context,
                        text: "User not logged in!",
                        backgroundColor: Colors.red);

                    return;
                  }

                  // ─── Parse values ──────────────────────────────────────
                  final gram = int.tryParse(_weightController.text);
                  final calories = double.tryParse(_caloriesController.text);
                  final protein = double.tryParse(_proteinController.text);
                  final fat = double.tryParse(_fatController.text);
                  final carbs = double.tryParse(_carbsController.text);

                  // ─── Null / invalid number check ──────────────────────
                  if (gram == null || calories == null ||
                      protein == null || fat == null || carbs == null) {
                    UiHelper.showToast(context: context,
                        text: "Please enter valid numbers in all fields!",
                        backgroundColor: Colors.red);

                    return;
                  }

                  // ─── Empty food name check ─────────────────────────────
                  if (_foodNameController.text
                      .trim()
                      .isEmpty) {
                    UiHelper.showToast(context: context,
                        text: "Food name cannot be empty!",
                        backgroundColor: Colors.red);

                    return;
                  }

                  // ─── All good — add food ───────────────────────────────
                  provider.addfood(
                    userid: user.uid,
                    selectedDate: home.selectedDate,
                    gram: gram,
                    food: null,
                    foodName: _foodNameController.text.trim(),
                    manualCalories: calories,
                    manualProtein: protein,
                    manualFat: fat,
                    manualCarbs: carbs,
                  );

                  Navigator.pop(context);
                  UiHelper.showToast(context: context,
                      text: "Meal added successfully!",
                      backgroundColor: Colors.green);
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: Colors.white, // ← text color here

        ),
        decoration: InputDecoration(
          labelText: label,

          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 14),
        ),
      ),
    );
  }


}
