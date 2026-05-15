import 'package:flutter/material.dart';

void main() {
  runApp(const RecipeSearchApp());
}

class RecipeSearchApp extends StatelessWidget {
  const RecipeSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Search Mobile',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Demo Recipe Search Mobile Skeleton\nConnect dataset to start'),
        ),
      ),
    );
  }
}