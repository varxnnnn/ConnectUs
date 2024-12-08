import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:project1/features/app/user_auth/presentation/pages/mainScreen.dart';
import 'features/app/user_auth/presentation/api/conts.dart';
import 'features/app/user_auth/presentation/pages/Logs/login_page.dart';
import 'features/app/user_auth/presentation/pages/Logs/splash.dart';
import 'features/app/user_auth/presentation/pages/Logs/sign_up_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization for web and mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCJIBgLZ7dRvXEwI-geUYQQGvZkjBtc93w",
        authDomain: "project1-3ec47.firebaseapp.com",
        projectId: "project1-3ec47",
        storageBucket: "project1-3ec47.appspot.com",
        messagingSenderId: "54093045141",
        appId: "1:54093045141:web:ab23c65c25b6513b8b6a9c",
        measurementId: "G-6PTF5Y4SRQ",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define your gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF041A2E), // Dark blue
      Color(0xFF193356), // Deep blue/teal
      Color(0xFF041D33), // Dark blue
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.1, 0.7, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF0D6EC5), // Fallback primary color
          onBackground: Colors.black,
          error: Colors.red,
        ),
        scaffoldBackgroundColor: Colors.transparent, // Transparent for gradient
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF0D6EC5),
          foregroundColor: Colors.white,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF7E6377),
          textTheme: ButtonTextTheme.primary,
        ),
        cardColor: const Color(0xFF7D7F88),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const GradientBackground(child: SplashScreen()),
        '/login': (context) => const GradientBackground(child: LoginPage()),
        '/signup': (context) => const GradientBackground(child: SignUpPage()),
        '/home': (context) => const GradientBackground(child: MainScreen()),
      },
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: MyApp.primaryGradient,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent, // Ensure gradient shows through
          body: child,
        ),
      ),
    );
  }
}
