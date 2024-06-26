import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:me_good/screens/good_screen.dart';
import 'package:me_good/screens/calendar_screen.dart';
import 'package:me_good/router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tab = <Tab>[
    const Tab(text: 'いいね'),
    const Tab(text: 'カレンダー'),
  ];

  final focusNode = FocusNode();

  bool isLoading = false;

  Future<String?> getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        return build.id; // AndroidのデバイスID
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        return data.identifierForVendor; // iOSのデバイスID
      }
    } catch (e) {
      print('Failed to get device ID: $e');
    }
    return "unknown";
  }

  // データ削除
  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("全てのきろくを削除しますか?"),
          content: const Text("この操作は取り消せません。"),
          actions: [
            CupertinoDialogAction(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () async {
                deleteData();
                Navigator.pop(context);
              },
              isDestructiveAction: true, // これにより、ボタンが赤くなります（危険な操作を示すため）
            ),
          ],
        );
      },
    );
  }

  void deleteData() async {
    final deviceId = await getDeviceId();

    if (deviceId == "unknown") return; // デバイスIDが取得できない場合は、処理を中断

    // deviceIdで指定されたコレクションのドキュメントをすべて取得
    final userCollection = FirebaseFirestore.instance.collection(deviceId!);
    final docs = await userCollection.get();

    // それぞれのドキュメントを削除
    for (final doc in docs.docs) {
      await doc.reference.delete();
    }

    goRouter.go('/');

    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text("データを削除しました!"),
            actions: [
              CupertinoDialogAction(
                child: const Text('閉じる'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  @override
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
            title: const Text('me good'),
            actions: const [
              // 通知ボタン
              notification_setting()
            ],
            toolbarHeight: 50,
            elevation: 0.0,
            backgroundColor:
                const HSLColor.fromAHSL(1.0, 30, 1.0, 0.75).toColor(),
            //shadowColor: Colors.black,
            bottom: TabBar(
              indicatorColor:
                  const HSLColor.fromAHSL(1.0, 10, 1.0, 0.75).toColor(),
              indicatorWeight: 5,
              tabs: _tab,
              labelStyle:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
            leading: IconButton(
                onPressed: () => showDeleteConfirmationDialog(context),
                icon: const Icon(Icons.delete)),
          ),
          body: const TabBarView(children: <Widget>[
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
  final FlutterLocalNotificationsPlugin flnp =
      FlutterLocalNotificationsPlugin();

  // 通知設定
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay nowTime = TimeOfDay.now();

  Timer? timer;

  Future<TimeOfDay?> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor:
                  const HSLColor.fromAHSL(1.0, 33, 1.0, 0.85).toColor(),
              dialBackgroundColor:
                  const HSLColor.fromAHSL(1.0, 33, 1.0, 0.85).toColor(),
              dialHandColor: Colors.deepOrangeAccent,
              hourMinuteColor:
                  const HSLColor.fromAHSL(1.0, 33, 1.0, 0.85).toColor(),
              hourMinuteTextColor: Colors.deepOrange,
            ),
            colorScheme: const ColorScheme.light().copyWith(
                primary: Colors.orange), // OKボタンとキャンセルボタンのテキストの色をオレンジに設定
            hintColor: Colors.deepOrange,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      return picked;
    }
    return null;
  }

  Future<void> notify() async {
    final jst = tz.getLocation('Asia/Tokyo'); // 日本のタイムゾーンを取得

    // 選択された時間に基づく今日の日本時間を取得
    final scheduledTime = tz.TZDateTime(
        jst,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        selectedTime.hour,
        selectedTime.minute);

    return flnp
        .initialize(
          const InitializationSettings(
            iOS: DarwinInitializationSettings(),
          ),
        )
        .then((_) => flnp.zonedSchedule(
              0,
              'me good ',
              '今日一日をふり返ろう👍',
              scheduledTime,
              const NotificationDetails(
                iOS: DarwinNotificationDetails(),
              ),
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents:
                  DateTimeComponents.time, // 毎日の指定した時刻にマッチさせる
            ));
  }

  // selectedTime を保存する
  Future<void> _saveSelectedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("selectedHour", selectedTime.hour);
    await prefs.setInt("selectedMinute", selectedTime.minute);
  }

  // selectedTime を読み込む
  Future<void> _loadSelectedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedHour = prefs.getInt("selectedHour");
    int? storedMinute = prefs.getInt("selectedMinute");
    if (storedHour != null && storedMinute != null) {
      setState(() {
        selectedTime = TimeOfDay(hour: storedHour, minute: storedMinute);
      });
    }
  }

  // _giveVerseを保存する
  Future<void> _saveGiveVerseState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("_giveVerse", _giveVerse);
  }

  // _giveVerseを読み込む
  Future<void> _loadGiveVerseState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? storedState = prefs.getBool("_giveVerse");
    if (storedState != null) {
      setState(() {
        _giveVerse = storedState;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedTime();
    _loadGiveVerseState();

    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings =
        InitializationSettings(iOS: initializationSettingsIOS);
    flnp.initialize(initializationSettings);

    // 追加: 初期化時に現在時刻を1秒ごとに更新するTimerを設定
    timer = Timer.periodic(
      const Duration(seconds: 1),
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

  bool _giveVerse = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          // notification
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              backgroundColor:
                  const HSLColor.fromAHSL(1.0, 33, 1.0, 0.85).toColor(),
              context: context,
              isScrollControlled: true,
              builder: (BuildContext bc) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setStateModal) {
                  return Container(
                    padding: const EdgeInsets.only(top: 0.0),
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close))
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            const Text('リマインドタイム'),
                            Text(
                              '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 50.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final picked = await selectTime(context);
                                if (picked != null && picked != selectedTime) {
                                  setStateModal(() {
                                    selectedTime = picked;
                                  });
                                  _saveSelectedTime();
                                  notify();
                                }
                              },
                              child: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Switch(
                              value: _giveVerse,
                              activeColor: Colors.orange,
                              onChanged: (bool newValue) {
                                setStateModal(() {
                                  _giveVerse = newValue;
                                });

                                _saveGiveVerseState();

                                if (newValue) {
                                  notify();
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                });
              });
        },
        icon: const Icon(Icons.notification_add));
  }
}
