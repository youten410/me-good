import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:me_good/screens/good_screen.dart';
import 'package:me_good/screens/calendar_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:me_good/router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tab = <Tab>[
    Tab(text: 'いいね'),
    Tab(text: 'カレンダー'),
  ];

  final focusNode = FocusNode();

  bool isLoading = false;

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // キーボードを閉じる
      },
      child: DefaultTabController(
        length: _tab.length,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    goRouter.go('/');
                    showDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text("ログアウトしました。"),
                            actions: [
                              CupertinoDialogAction(
                                child: Text('OK'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          );
                        });
                  },
                  icon: Icon(Icons.logout_outlined))
            ],
            toolbarHeight: 50,
            elevation: 0.0,
            backgroundColor: HSLColor.fromAHSL(1.0, 30, 1.0, 0.75).toColor(),
            //shadowColor: Colors.black,
            bottom: TabBar(
              indicatorColor: HSLColor.fromAHSL(1.0, 10, 1.0, 0.75).toColor(),
              indicatorWeight: 5,
              tabs: _tab,
            ),
          ),
          body: TabBarView(children: <Widget>[
            GoodScreen(),
            CalendarScreen(),
          ]),
        ),
      ),
    );
  }
}
