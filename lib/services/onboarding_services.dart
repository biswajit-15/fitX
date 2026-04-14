import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../Model/onboarding_Screens.dart';

class OnboardingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> saveOnboarding(OnboardingData data) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }
 try{
   await _db.child("users")
       .child(user.uid)
       .child("profile")
       .update(data.toJson());
 }catch(e){
   throw Exception("Something is wrong");

 }

  }
}