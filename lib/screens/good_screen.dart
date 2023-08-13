import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flat_3d_button/flat_3d_button.dart';
import 'package:pushable_button/pushable_button.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GoodScreen extends StatefulWidget {
  const GoodScreen({super.key});

  @override
  State<GoodScreen> createState() => _GoodScreenState();
}

class _GoodScreenState extends State<GoodScreen> {
  // Get a non-default Storage bucket
  final storage =
      FirebaseStorage.instanceFor(bucket: "gs://me-good-2575b.appspot.com");
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
              // いいねボタン
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isElevated = !_isElevated;
                    goodCount++;
                  });
                  // 1秒後に元の状態に戻す
                  Future.delayed(Duration(milliseconds: 500), () {
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
                        color: HSLColor.fromAHSL(1.0, 40, 1.0, 0.75)
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
                    Icon(
                      Icons.favorite,
                      color: Colors.deepOrangeAccent,
                      size: 70,
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 30,
          ),
          // テキストフィールド
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              // boxShadow: [
              //   BoxShadow(
              //       color: Colors.black12,
              //       blurRadius: 10.0,
              //       spreadRadius: 1.0,
              //       offset: Offset(10, 10))
              // ],
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
                // shadow: shadow,
                onPressed: () {
                  if (goodCount != 0 && comment.isNotEmpty) {
                    DateTime now = DateTime.now();
                    DateTime date = DateTime(now.year, now.month, now.day);
                    String dateString =
                        DateFormat('yyyy-MM-dd').format(date); // 日付を文字列に変換
                    saveData(dateString, goodCount, comment);
                    // モーダルの表示　バツボタンの位置は上に保持したい
                    showModalBottomSheet(
                        backgroundColor: Colors.white,
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
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            right: 20.0, left: 20.0),
                                        child: Text(
                                          '$goodCountいいね!\n素晴らしい!今日も自分を褒めてあげよう!',
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                          height: 500,
                                          width: 300,
                                          child: Image.network(
                                              'https://img.freepik.com/free-vector/happy-young-couple-having-fun-girl-guy-dancing-party-celebrating-good-news-flat-illustration_74855-10820.jpg?w=1380&t=st=1691891370~exp=1691891970~hmac=7ee022a53aa90f8c7ce8e3b35c9c61d014ebab5c5259a2117c54ae77e9e40453'))
                                    ],
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
