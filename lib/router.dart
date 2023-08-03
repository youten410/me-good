import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:me_good/screens/home_screen.dart';
import 'package:me_good/screens/calendar_screen.dart';
import 'package:me_good/screens/positive_feedback.dart';

final GoRouter goRouter = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          return MaterialPage(child: HomeScreen());
        }),
    GoRoute(
        path: '/calender',
        pageBuilder: (context, state) {
          return MaterialPage(child: (CalendarScreen()));
        }),
    GoRoute(
        path: '/positive-feedback',
        pageBuilder: (context, state) {
          return MaterialPage(child: (PositiveFeedback()));
        }),
  ],
);
