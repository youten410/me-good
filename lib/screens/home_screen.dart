import 'package:flutter/material.dart';
import 'package:me_good/screens/good_screen.dart';
import 'package:me_good/screens/calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tab = <Tab>[
    Tab(text: 'いいね', icon: Icon(Icons.thumb_up)),
    Tab(text: 'カレンダー', icon: Icon(Icons.calendar_month)),
  ];

  final focusNode = FocusNode();

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // キーボードを閉じる
      },
      child: DefaultTabController(
        length: _tab.length,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 20,
            elevation: 0.0,
            backgroundColor: HSLColor.fromAHSL(1.0, 30, 1.0, 0.75).toColor(),
            //shadowColor: Colors.black,
            bottom: TabBar(
              indicatorColor: HSLColor.fromAHSL(1.0, 10, 1.0, 0.75).toColor(),
              indicatorWeight: 5,
              tabs: _tab,
            ),
          ),
          body: TabBarView(children: <Widget>[GoodScreen(), CalendarScreen()]),
        ),
      ),
    );
  }
}
