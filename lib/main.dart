import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CamouflageScreen.dart';
import 'PasswordSetupScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isPasswordSet = prefs.getBool('isPasswordSet') ?? false;
  runApp(MyApp(isPasswordSet: isPasswordSet));
}

class MyApp extends StatelessWidget {
  final bool isPasswordSet;
  MyApp({required this.isPasswordSet});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Setup Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: isPasswordSet ? CamouflageScreen() : PasswordSetupScreen(),
    );
  }
}
