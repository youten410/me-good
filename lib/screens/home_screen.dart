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

  // ログアウト
  void logoutUser() async {
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
  }
  String selectedValue = 'ログアウト';
  final lists = ['ログアウト', '退会', '問い合わせ'];
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // キーボードを閉じる
      },
      child: DefaultTabController(
        length: _tab.length,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Icon(Icons.developer_mode),
            leading: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) {
                  return lists.map((String list) {
                    return PopupMenuItem(
                      value: list,
                      child: Text(list),
                    );
                  }).toList();
                },
                onSelected: (String list) {
                  setState(() {
                    selectedValue = list;

                    if (list == 'ログアウト') {
                      print('ログアウト');
                      logoutUser();
                    } else if (list == '退会') {
                      print('退会');
                      //deleteUser();
                    } else {
                      print('問い合わせ');
                    }
                  });
                }),
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
