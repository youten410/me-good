import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flat_3d_button/flat_3d_button.dart';
import 'package:pushable_button/pushable_button.dart';

class GoodScreen extends StatefulWidget {
  const GoodScreen({super.key});

  @override
  State<GoodScreen> createState() => _GoodScreenState();
}

class _GoodScreenState extends State<GoodScreen> {
  TextEditingController _titleController = TextEditingController();
  bool _titleCompleted = false;
  late String comment;
  int goodCount = 0;
  late Timestamp date;
  bool _isElevated = true;

  void resetData() {
    _titleController.clear();
    comment = '';
    goodCount = 0;
  }

  void saveData(String date, int goodCount, String comment) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('UserGoodCounts');
    // コレクション名は後でuserID(匿名)にする

    users.doc(date).set({'goodCount': goodCount, 'comment': comment});
  }

  final shadow = BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    spreadRadius: 5,
    blurRadius: 7,
    offset: const Offset(0, 2),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: HSLColor.fromAHSL(1.0, 33, 1.0, 0.85).toColor(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'テスト',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 30,
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Column(
            children: [
              Container(
                width: 200,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text("✖️ $goodCount"),
                ]),
              ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isElevated = !_isElevated;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(50),
              boxShadow: _isElevated
                  ? [
                      const BoxShadow(
                        color: Colors.grey,
                        offset: Offset(4, 4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(10, 10))
              ],
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
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'コメント',
                          hintStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 20.0),
                        ),
                        maxLength: 100,
                        maxLines: null,
                        style: TextStyle(fontSize: 15),
                        onChanged: (text) => setState(() {
                              _titleCompleted = text.isNotEmpty;
                              comment = _titleController.text.toString();
                            })))),
          ),
          SizedBox(
            height: 40,
          ),
          Center(
            child: Container(
              width: 300,
              child: PushableButton(
                child: const Text(
                  'きろく',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                height: 60,
                elevation: 8,
                hslColor: const HSLColor.fromAHSL(1.0, 30, 1.0, 0.75),
                shadow: shadow,
                                onPressed: () {
                  if (goodCount != 0 && comment.isNotEmpty) {
                    DateTime now = DateTime.now();
                    DateTime date = DateTime(now.year, now.month, now.day);
                    String dateString =
                        DateFormat('yyyy-MM-dd').format(date); // 日付を文字列に変換
                    saveData(dateString, goodCount, comment);
                    // モーダルの表示　バツボタンの位置は上に保持したい
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext bc) {
                          return Container(
                            padding: EdgeInsets.only(top: 100.0),
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
                                          setState(() {
                                            resetData();
                                          });
                                        },
                                        icon: Icon(Icons.close))
                                  ],
                                ),
                                Container(
                                  child: Text(
                                    '今日は、$goodCountいいね!\nできたね!\n自分にご褒美を!',
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          );
                        });
                  } else {
                    // モーダル？か何かで表示（上から出るやつとか
                    print("どちらかが不足");
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
