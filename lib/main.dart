import 'package:flutter/material.dart';
import 'home_screen.dart'; // Aquí importamos la pantalla principal

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Tracker',
      debugShowCheckedModeBanner: false, // Quita la etiqueta de "DEBUG"
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(), 
    );
  }
}