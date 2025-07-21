import 'package:flutter/material.dart';
import 'screens/home_page.dart'; // Correct relative import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vital App',
      theme: ThemeData.dark(),

      // 👇 Starts directly at HomePage
      home: const HomePage(),
    );
  }
}
