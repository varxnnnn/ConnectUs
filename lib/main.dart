import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:project1/features/app/user_auth/presentation/pages/mainScreen.dart';
import 'features/app/user_auth/presentation/pages/Logs/splash.dart';
import 'features/app/user_auth/presentation/pages/students/chatBot/consts.dart';
import 'features/app/user_auth/presentation/pages/Logs/login_page.dart';
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

  // Define your custom colors
  static const Color primaryColor = Color(0xFF090909); // Dark primary color
  static const Color secondaryColor = Color(0xFFF9AA33);
  static const Color darkColor = Colors.white; // Text on dark backgrounds
  static const Color grayColor = Color(0xFF7D7F88); // Gray for secondary text
  static const Color accentColor = Color(0xFF7E6377); // Accent color for buttons

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          background: primaryColor,
          surface: primaryColor,
          onPrimary: darkColor,
          onSecondary: darkColor,
          onSurface: darkColor,
          onBackground: darkColor,
          error: Colors.red,
        ),
        scaffoldBackgroundColor: primaryColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: darkColor, fontSize: 16),
          bodyMedium: TextStyle(color: grayColor, fontSize: 14),
          displayLarge: TextStyle(color: darkColor, fontSize: 36, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: darkColor, fontSize: 24),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: accentColor,
          textTheme: ButtonTextTheme.primary,
        ),
        cardColor: grayColor,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => MainScreen(),
      },
    );
  }
}
