import 'package:flutter/material.dart';
import '../Model/onboarding_Screens.dart';
import '../services/onboarding_services.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingData _data = OnboardingData();
  int _currentStep = 0;

  final int totalSteps = 6;

  OnboardingData get data => _data;
  int get currentStep => _currentStep;
  double get progress => (_currentStep + 1) / totalSteps;

  void setMainGoal(String goal) {
    _data.goal = goal;
    notifyListeners();
  }
  final OnboardingService _service = OnboardingService();

  Future<void> completeOnboarding() async {
    await _service.saveOnboarding(data);
  }
  void setGender(String gender) {
    _data.gender = gender;
    notifyListeners();
  }

  void setAge(int age) {
    _data.age = age;
    notifyListeners();
  }

  void setHeight(int height) {
    _data.height = height;
    notifyListeners();
  }

  void setWeight(int weight) {
    _data.weight = weight;
    notifyListeners();
  }

  void setDietType(String dietType) {
    _data.dietType = dietType;
    notifyListeners();
  }


  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++
      ;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void reset() {
    _data = OnboardingData();
    _currentStep = 0;
    notifyListeners();
  }
}