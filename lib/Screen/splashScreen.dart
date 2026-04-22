import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});

@override
State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      _checkNavigation();
    });
  }

  Future<void> _checkNavigation() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("users/${user.uid}/profile/profileCompleted")
          .get();

      final completed = snapshot.value == true;

      if (!mounted) return;

      if (completed) {
        Navigator.pushReplacementNamed(context, '/bottomNavigation');
      } else {
        Navigator.pushReplacementNamed(context, '/OnboardingFlow');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'Assets/Images/splashScreen.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}