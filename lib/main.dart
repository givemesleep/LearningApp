
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/auth/auth.dart';
import 'package:flutter_application_1/theme/dark_mode.dart';
import 'package:flutter_application_1/theme/light_mode.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //  home: LoginPage(),
      //  home: HomePage(),
      // home: RegisterPage(),
      home: const AuthPage(),
      theme: darkMode,
      darkTheme: lightmode,
    );
  }
}