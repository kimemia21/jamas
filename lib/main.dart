import 'package:flutter/material.dart';
import 'package:jamas/auth/Signup.dart';
import 'package:jamas/auth/ToutLogin.dart';
import 'package:jamas/auth/UserLogin.dart';
import 'package:jamas/features/tout/ToutHomepage.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main()async {

 await  WidgetsFlutterBinding.ensureInitialized();
 bool isAvailable = await NfcManager.instance.isAvailable();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jamas App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:  LoginPage()
      // Toutlogin()
          // Toutlogin()
          //  LoginPage()
          //  RegistrationPage()
          // ToutHomePage(),
    );
  }
}
