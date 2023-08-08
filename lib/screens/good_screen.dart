import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              '今日の自分にGood!',
              style: TextStyle(color: Colors.deepPurple, fontSize: 30),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Center(
            child: Column(
              children: [
                Container(
                  width: 200,
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text("✖️ $goodCount"),
                  ]),
                ),
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  iconSize: 200,
                  color: const Color.fromARGB(255, 255, 207, 34),
                  onPressed: () {
                    setState(() {
                      goodCount += 1;
                    });
                  },
                ),
              ],
            ),
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
                    width: MediaQuery.of(context).size.width * 1.0,
                    height: MediaQuery.of(context).size.width * 0.2,
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
                        maxLength: 14,
                        maxLines: null,
                        style: TextStyle(fontSize: 20),
                        onChanged: (text) => setState(() {
                              _titleCompleted = text.isNotEmpty;
                              comment = _titleController.text.toString();
                            })))),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: TextButton(
                onPressed: () {
                  if (goodCount != 0 && comment.isNotEmpty) {
                    DateTime now = DateTime.now();
                    DateTime date = DateTime(now.year, now.month, now.day);
                    String dateString =
                        DateFormat('yyyy-MM-dd').format(date); // 日付を文字列に変換
                    saveData(dateString, goodCount, comment);
                    // モーダルの表示
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext bc) {
                          return Container(
                            padding: EdgeInsets.only(top: 40.0),
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                ListTile(
                                    title: Text('適当な文字列'),
                                    trailing: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )),
                              ],
                            ),
                          );
                        });
                  } else {
                    print("どちらかが不足");
                  }
                },
                child: Text(
                  "きろく",
                  style:TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                  )),
          ),
        ],
      ),
    );
  }
}
