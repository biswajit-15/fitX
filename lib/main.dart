import 'package:firebase_core/firebase_core.dart';
import 'package:fitx/Screen/bottom_Navigation.dart';
import 'package:fitx/Screen/splashScreen.dart';
import 'package:flutter/material.dart';
import 'Provider/addMeal_provider.dart';
import 'Provider/history_provider.dart';
import 'Provider/home_provider.dart';
import 'Screen/homeScreen.dart';
import 'Screen/loginScreen.dart';
import 'Screen/onboarding_flow.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// test change
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> Addmeal()),
        ChangeNotifierProvider(create: (_) => homeprovider(),),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),

      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
      
         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/splash',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/OnboardingFlow': (context) => const OnboardingFlow(),
          '/bottomNavigation':(context)=>const BottomNavigation (),
          '/splash':(context)=>const SplashScreen(),
        },
      ),
    );
  }
}
