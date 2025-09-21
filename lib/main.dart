import 'package:flutter/material.dart';
import 'package:prelex_2/view/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

