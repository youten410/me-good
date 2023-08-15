import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:me_good/screens/good_screen.dart';
import 'package:me_good/screens/calendar_screen.dart';
import 'package:me_good/screens/home_screen.dart';
import 'package:me_good/screens/feedback_screen.dart';
import 'package:me_good/screens/login_page.dart';

final GoRouter goRouter = GoRouter(
  routes: [
    GoRoute(
        path: '/home',
        pageBuilder: (context, state) {
          return MaterialPage(child: HomeScreen());
        }),
    GoRoute(
        path: '/feedBack',
        pageBuilder: (context, state) {
          return MaterialPage(child: PositiveFeedback());
        }),
    GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          return MaterialPage(child: LoginPage());
        }),
  ],
);
