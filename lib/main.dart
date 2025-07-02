import 'package:flutter/material.dart';
import 'package:jamas/auth/Signup.dart';
import 'package:jamas/features/tout/ToutHomepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jamas App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ToutHomePage(),
     );
  }
}