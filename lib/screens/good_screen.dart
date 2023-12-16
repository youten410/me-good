import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pushable_button/pushable_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:blur/blur.dart';
import 'package:flutter/services.dart';
import 'package:me_good/key.dart';

class GoodScreen extends StatefulWidget {
  const GoodScreen({super.key});

  @override
  State<GoodScreen> createState() => _GoodScreenState();
}

class _GoodScreenState extends State<GoodScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool titleCompleted = false;
  String comment = '';

  int goodCount = 0;
  late Timestamp date;
  bool _isElevated = true;
  bool isLoading = false;

  void resetData() {
    _titleController.clear();
    comment = '';
    goodCount = 0;
  }

  String? uid;

  @override
  void initState() {
    super.initState();
    getDeviceId().then((deviceId) {
      setState(() {
        uid = deviceId;
      });
    });
  }

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

  void saveData(String date, int goodCount, String comment) async {
    CollectionReference users = FirebaseFirestore.instance.collection(uid!);
    users.doc(date).set({'goodCount': goodCount, 'comment': comment});
  }

  final shadow = BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    spreadRadius: 5,
    blurRadius: 7,
    offset: const Offset(0, 2),
  );

  final focusNode = FocusNode();

  // openAI API
  String? advice;
  String? _imageUrl;

  Future<void> getAdvice(comment) async {
    setState(() {
      isLoading = true; // ローダー開始
    });

    try {
      OpenAI.apiKey = key;

      final completion = await OpenAI.instance.completion.create(
        model: "text-davinci-003",
        prompt:
            '$commentに対して、カウンセラー風に日本語でアドバイスをお願いします。文末は「〜ましょう」で終わるようにしてください。文字数は50文字ぴったりでお願いします。',
        maxTokens: 200,
      );

      advice = completion.choices[0].text;

      print('アドバイス $advice');

      final image = await OpenAI.instance.image.create(
        prompt: "$adviceの内容に対して、リラックスや休息をイメージする画像を生成してください。",
        n: 1,
        size: OpenAIImageSize.size256,
      );
      _imageUrl = image.data.first.url;

      print(_imageUrl);
    } finally {
      setState(() {
        isLoading = false; // ローダー終了
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const HSLColor.fromAHSL(1.0, 33, 1.0, 0.85).toColor(),
      body: Stack(
        children: <Widget>[
          // ここからが本来のコンテンツ
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus(); // キーボードを閉じる
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 60,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "♡ $goodCount",
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.orangeAccent),
                              ),
                            ]),
                      ),
                      // いいねボタン
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          setState(() {
                            _isElevated = !_isElevated;
                            goodCount++;
                          });
                          // 1秒後に元の状態に戻す
                          Future.delayed(const Duration(milliseconds: 500), () {
                            setState(() {
                              _isElevated = true;
                            });
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 200,
                              ),
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                color:
                                    const HSLColor.fromAHSL(1.0, 40, 1.0, 0.75)
                                        .toColor(), // 面の色
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: _isElevated
                                    ? [
                                        const BoxShadow(
                                          color: Colors.grey, //右下のシャドーの色
                                          offset: Offset(3, 3),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                        const BoxShadow(
                                          color: Colors.white, // 左上のシャドーの色
                                          offset: Offset(-3, -3),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [
                                        // フラットになりすぎないよう、小さなシャドウを残す
                                        const BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                          spreadRadius: 1,
                                        ),
                                        const BoxShadow(
                                          color: Colors.white,
                                          offset: Offset(-1, -1),
                                          blurRadius: 2,
                                          spreadRadius: 1,
                                        ),
                                      ],
                              ),
                            ),
                            const Icon(
                              Icons.favorite,
                              color: Colors.deepOrangeAccent,
                              size: 100,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  // テキストフィールド
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus(); // キーボードを閉じる
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.width * 0.4,
                            alignment: Alignment.centerLeft,
                            child: TextFormField(
                                focusNode: focusNode,
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  hintText: 'コメント',
                                  hintStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 20.0),
                                ),
                                maxLength: 100,
                                maxLines: null,
                                style: const TextStyle(fontSize: 15),
                                onChanged: (text) => setState(() {
                                      titleCompleted = text.isNotEmpty;
                                      comment =
                                          _titleController.text.toString();
                                    })))),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: PushableButton(
                        height: 60,
                        elevation: 8,
                        hslColor: const HSLColor.fromAHSL(1.0, 30, 1.0, 0.75),
                        onPressed: () async {
                          if (goodCount != 0 && comment.isNotEmpty) {
                            // openAI APIを実行
                            await getAdvice(comment);
                            DateTime now = DateTime.now();
                            DateTime date =
                                DateTime(now.year, now.month, now.day);
                            String dateString = DateFormat('yyyy-MM-dd')
                                .format(date); // 日付を文字列に変換
                            saveData(dateString, goodCount, comment);
                            showModalBottomSheet(
                                backgroundColor:
                                    HSLColor.fromAHSL(1.0, 33, 1.0, 0.85)
                                        .toColor(),
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext bc) {
                                  return Container(
                                    padding: EdgeInsets.only(top: 50.0),
                                    height: MediaQuery.of(context).size.height,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    resetData();
                                                  });
                                                },
                                                icon: Icon(Icons.close))
                                          ],
                                        ),
                                        Container(
                                          color: HSLColor.fromAHSL(
                                                  1.0, 33, 1.0, 0.85)
                                              .toColor(),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    right: 20.0, left: 20.0),
                                                child: Text(
                                                  '$advice\n(AIアドバイス)',
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                height: 200,
                                                width: 200,
                                                child:
                                                    Image.network(_imageUrl!),
                                              ),
                                              SizedBox(
                                                height: 25,
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    Share.share(
                                                        '今日は$goodCountいいねしました👏');
                                                  },
                                                  icon: Icon(
                                                    Icons.share,
                                                    size: 30,
                                                    color: Colors.orangeAccent,
                                                  ))
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                });
                          } else {
                            print("どちらかが不足");
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text("未入力です"),
                                    content: const Text("「いいね」と「コメント」両方入力してね"),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text('OK'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  );
                                });
                          }
                        },
                        child: const Text(
                          'きろく',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const Blur(
              child: SizedBox(
                height: 800,
                width: 400,
              ),
            ),
          // ローダーの表示
          if (isLoading)
            const Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  strokeWidth: 10,
                  backgroundColor: Colors.white,
                  color: Colors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
