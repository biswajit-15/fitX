import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentStep = 0;

  // Controllers
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // User selections
  String _gender = "Male";
  String _goal = "Lose Fat";
  String _diet = "Vegetarian";
  String _activityLevel = "Moderate";

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // =============================
  // VALIDATION
  // =============================
  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_ageController.text.trim().isEmpty ||
          _heightController.text.trim().isEmpty ||
          _weightController.text.trim().isEmpty) {
        _showSnackBar('Please fill all fields', isError: true);
        return false;
      }

      final age = int.tryParse(_ageController.text.trim());
      final height = double.tryParse(_heightController.text.trim());
      final weight = double.tryParse(_weightController.text.trim());

      if (age == null || age < 13 || age > 120) {
        _showSnackBar('Please enter a valid age (13-120)', isError: true);
        return false;
      }
      if (height == null || height < 50 || height > 300) {
        _showSnackBar('Please enter a valid height (50-300 cm)', isError: true);
        return false;
      }
      if (weight == null || weight < 20 || weight > 500) {
        _showSnackBar('Please enter a valid weight (20-500 kg)', isError: true);
        return false;
      }
    }
    return true;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // =============================
  // NAVIGATION
  // =============================
  void _nextStep() {
    if (!_validateCurrentStep()) return;

    if (_currentStep < 3) {
      _pageController.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
      _animationController.forward(from: 0);
    } else {
      _saveProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
      _animationController.forward(from: 0);
    }
  }

  // =============================
  // SAVE PROFILE
  // =============================
  Future<void> _saveProfile() async {
    setState(() => _loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Calculate BMI for additional insights
      final height = double.parse(_heightController.text.trim()) / 100; // convert to meters
      final weight = double.parse(_weightController.text.trim());
      final bmi = weight / (height * height);

      await FirebaseDatabase.instance.ref("users/$uid/profile").update({
        "age": int.parse(_ageController.text.trim()),
        "gender": _gender,
        "height": double.parse(_heightController.text.trim()),
        "weight": double.parse(_weightController.text.trim()),
        "goal": _goal,
        "dietType": _diet,
        "activityLevel": _activityLevel,
        "bmi": bmi.toStringAsFixed(1),
        "profileCompleted": true,
        "completedAt": DateTime.now().toIso8601String(),
      });

      if (mounted) {
        _showSnackBar('Profile saved successfully!');
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save profile: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // =============================
  // UI BUILD
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
              const Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  _buildProgressIndicator(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildBodyInfoStep(),
                        _buildGoalStep(),
                        _buildDietStep(),
                        _buildActivityStep(),
                      ],
                    ),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
              if (_loading) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // =============================
  // HEADER
  // =============================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              if (_currentStep > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: _previousStep,
                )
              else
                const SizedBox(width: 48),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  'Step ${_currentStep + 1} of 4',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _getStepTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getStepSubtitle(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Body Metrics';
      case 1:
        return 'Your Goal';
      case 2:
        return 'Diet Preference';
      case 3:
        return 'Activity Level';
      default:
        return '';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Tell us about your body';
      case 1:
        return 'What do you want to achieve?';
      case 2:
        return 'Your dietary preference';
      case 3:
        return 'How active are you?';
      default:
        return '';
    }
  }

  // =============================
  // PROGRESS INDICATOR
  // =============================
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF00ff87)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: const Color(0xFF00ff87).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  // =============================
  // STEP 1: BODY INFO
  // =============================
  Widget _buildBodyInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              hint: 'Enter your age',
              icon: Icons.cake_outlined,
              suffix: 'years',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _heightController,
              label: 'Height',
              hint: 'Enter your height',
              icon: Icons.height,
              suffix: 'cm',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _weightController,
              label: 'Weight',
              hint: 'Enter your weight',
              icon: Icons.monitor_weight_outlined,
              suffix: 'kg',
            ),
            const SizedBox(height: 32),
            Text(
              'Gender',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGenderCard('Male', Icons.male),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderCard('Female', Icons.female),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: const Color(0xFF00ff87),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: const Color(0xFF00ff87), size: 24),
          ),
          suffixText: suffix,
          suffixStyle: const TextStyle(
            color: Color(0xFF00ff87),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          filled: false,
        ),
      ),
    );
  }

  Widget _buildGenderCard(String value, IconData icon) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF00ff87), Color(0xFF00cc6f)],
          )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00ff87)
                : Colors.white.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF00ff87).withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // STEP 2: GOAL
  // =============================
  Widget _buildGoalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildOptionCard(
              title: 'Lose Fat',
              subtitle: 'Burn calories and reduce body fat',
              icon: Icons.trending_down,
              value: 'Lose Fat',
              selectedValue: _goal,
              onTap: (value) => setState(() => _goal = value),
              gradient: const [Color(0xFFff6b6b), Color(0xFFee5a6f)],
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              title: 'Gain Muscle',
              subtitle: 'Build strength and muscle mass',
              icon: Icons.fitness_center,
              value: 'Gain Muscle',
              selectedValue: _goal,
              onTap: (value) => setState(() => _goal = value),
              gradient: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              title: 'Maintain',
              subtitle: 'Stay healthy and maintain current weight',
              icon: Icons.balance,
              value: 'Maintain',
              selectedValue: _goal,
              onTap: (value) => setState(() => _goal = value),
              gradient: const [Color(0xFF00ff87), Color(0xFF00cc6f)],
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // STEP 3: DIET
  // =============================
  Widget _buildDietStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildOptionCard(
              title: 'Vegetarian',
              subtitle: 'Plant-based diet with no meat',
              icon: Icons.eco,
              value: 'Vegetarian',
              selectedValue: _diet,
              onTap: (value) => setState(() => _diet = value),
              gradient: const [Color(0xFF56ab2f), Color(0xFFa8e063)],
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              title: 'Non-Vegetarian',
              subtitle: 'Includes meat and plant-based foods',
              icon: Icons.restaurant,
              value: 'NonVegetarian',
              selectedValue: _diet,
              onTap: (value) => setState(() => _diet = value),
              gradient: const [Color(0xFFf12711), Color(0xFFf5af19)],
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              title: 'Vegan',
              subtitle: 'Strict plant-based, no animal products',
              icon: Icons.spa,
              value: 'Vegan',
              selectedValue: _diet,
              onTap: (value) => setState(() => _diet = value),
              gradient: const [Color(0xFF00b09b), Color(0xFF96c93d)],
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // STEP 4: ACTIVITY LEVEL
  // =============================
  Widget _buildActivityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildOptionCard(
              title: 'Sedentary',
              subtitle: 'Little to no exercise',
              icon: Icons.weekend,
              value: 'Sedentary',
              selectedValue: _activityLevel,
              onTap: (value) => setState(() => _activityLevel = value),
              gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              title: 'Light',
              subtitle: 'Exercise 1-3 times per week',
              icon: Icons.directions_walk,
              value: 'Light',
              selectedValue: _activityLevel,
              onTap: (value) => setState(() => _activityLevel = value),
              gradient: const [Color(0xFFf093fb), Color(0xFFf5576c)],
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              title: 'Moderate',
              subtitle: 'Exercise 3-5 times per week',
              icon: Icons.directions_run,
              value: 'Moderate',
              selectedValue: _activityLevel,
              onTap: (value) => setState(() => _activityLevel = value),
              gradient: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              title: 'Very Active',
              subtitle: 'Exercise 6-7 times per week',
              icon: Icons.sports_gymnastics,
              value: 'Very Active',
              selectedValue: _activityLevel,
              onTap: (value) => setState(() => _activityLevel = value),
              gradient: const [Color(0xFFfa709a), Color(0xFFfee140)],
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              title: 'Extreme',
              subtitle: 'Intense training daily',
              icon: Icons.local_fire_department,
              value: 'Extreme',
              selectedValue: _activityLevel,
              onTap: (value) => setState(() => _activityLevel = value),
              gradient: const [Color(0xFFff6b6b), Color(0xFFffa500)],
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // REUSABLE OPTION CARD
  // =============================
  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String selectedValue,
    required Function(String) onTap,
    required List<Color> gradient,
  }) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradient) : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: gradient.first.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            )
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 28,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.white.withOpacity(0.3),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  // =============================
  // NAVIGATION BUTTONS
  // =============================
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00ff87), Color(0xFF00cc6f)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00ff87).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep < 3 ? 'Continue' : 'Complete Profile',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================
  // LOADING OVERLAY
  // =============================
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00ff87).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00ff87)),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'Creating your profile...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}