import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:me_good/router.dart';
import 'package:me_good/screens/home_screen.dart';
import 'package:me_good/screens/calendar_screen.dart';
import 'package:me_good/screens/positive_feedback.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
    );
  }
}