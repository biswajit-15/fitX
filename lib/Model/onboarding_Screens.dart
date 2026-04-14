class OnboardingData {
  String? goal;
  String? gender;
  int? age;
  int? height; // in cm
  int? weight; // in kg
  String? dietType;

  OnboardingData({
    this.goal,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.dietType,
  });

  bool get isComplete =>
      goal != null &&
          gender != null &&
          age != null &&
          height != null &&
          weight != null &&
          dietType != null ;

  Map<String, dynamic> toJson() => {
    'goal': goal,
    'gender': gender,
    'age': age,
    'height': height,
    'weight': weight,
    'dietType': dietType,
    'profileCompleted': true
  };
}