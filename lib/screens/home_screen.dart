import 'package:cloud_firestore/cloud_firestore.dart';
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

  // アカウント削除
  void deleteUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) return; // uidがnullの場合は、処理を中断

    // uidで指定されたコレクションのドキュメントをすべて取得
    final userCollection = FirebaseFirestore.instance.collection(uid);
    final docs = await userCollection.get();

    // それぞれのドキュメントを削除
    for (final doc in docs.docs) {
      await doc.reference.delete();
    }

    // ユーザーを削除
    await user?.delete();
    await FirebaseAuth.instance.signOut();

    print('ユーザーを削除しました!');

    goRouter.go('/');

    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("ご利用ありがとうございました！"),
            actions: [
              CupertinoDialogAction(
                child: Text('閉じる'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  // local notification
  Future<void> notify() {
    final flnp = FlutterLocalNotificationsPlugin();
    return flnp
        .initialize(
          InitializationSettings(
            iOS: DarwinInitializationSettings(),
          ),
        )
        .then((_) => flnp.show(0, 'title', 'body', NotificationDetails()));
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
            title: Text('me good'),
            actions: [
              IconButton(
                  onPressed: () {
                    // notification
                    showModalBottomSheet(
                        backgroundColor:
                            HSLColor.fromAHSL(1.0, 33, 1.0, 0.85).toColor(),
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext bc) {
                          return Container(
                            padding: EdgeInsets.only(top: 50.0),
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.close))
                                  ],
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  icon: Icon(Icons.notification_add))
            ],
            leading: PopupMenuButton<String>(
                constraints: BoxConstraints.expand(height: 150, width: 120),
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
                      deleteUser();
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

class notification_setting extends StatefulWidget {
  const notification_setting({
    super.key,
  });

  @override
  State<notification_setting> createState() => _notification_settingState();
}

class _notification_settingState extends State<notification_setting> {
  // 通知設定
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay nowTime = TimeOfDay.now();

  Timer? timer;

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }

    print(selectTime);
  }

  @override
  void initState() {
    super.initState();

    // 追加: 初期化時に現在時刻を1秒ごとに更新するTimerを設定
    timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer t) => setState(() {
        nowTime = TimeOfDay.now();
      }),
    );
  }

  @override
  void dispose() {
    // 追加: Timerを破棄
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          // notification
          showModalBottomSheet(
              backgroundColor: HSLColor.fromAHSL(1.0, 33, 1.0, 0.85).toColor(),
              context: context,
              isScrollControlled: true,
              builder: (BuildContext bc) {
                return Container(
                  padding: EdgeInsets.only(top: 50.0),
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close))
                        ],
                      ),
                      Center(
                        child: Container(
                            child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 50,
                            ),
                            Text(
                              '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 40.0),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                selectTime(context);
                              },
                              child: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),
                );
              });
        },
        icon: Icon(Icons.notification_add));
  }
}
