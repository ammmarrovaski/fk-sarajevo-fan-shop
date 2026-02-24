import 'package:flutter/material.dart';
import 'flavor_config/flavors.dart';
import 'pages/login_page.dart'; // Import koji si već dodao, super!

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: F.title,
      debugShowCheckedModeBanner: false, // Ovo briše onaj "Debug" baner u ćošku
      theme: ThemeData(
        primaryColor: const Color(0xFF800000),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800000)),
        useMaterial3: true, // Moderniji izgled elemenata
      ),
      // Umjesto starog Scaffold-a, samo stavi LoginPage
      home:  LoginPage(), 
    );
  }
}