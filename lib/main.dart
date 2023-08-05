import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:me_good/router.dart';
import 'package:me_good/screens/good_screen.dart';
import 'package:me_good/screens/calendar_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
    );
  }
}