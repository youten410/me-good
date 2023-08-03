import 'package:flutter/material.dart';
import 'package:me_good/screens/good_screen.dart';
import 'package:me_good/screens/calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tab = <Tab> [
    Tab( text:'Good', icon: Icon(Icons.thumb_up)),
    Tab( text:'Calender', icon: Icon(Icons.calendar_month)),
  ];

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tab.length,
      child: Scaffold(
        appBar: AppBar(
          title: Icon(Icons.logo_dev),
          bottom: TabBar(
            tabs: _tab,
          ),
        ),
        body: TabBarView(
            children: <Widget> [
              GoodScreen(),
              CalendarScreen()
            ]
        ),
      ),
    );
  }
}