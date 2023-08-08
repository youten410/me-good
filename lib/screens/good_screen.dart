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
          Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.2,
                color: Colors.grey,
                alignment: Alignment.centerLeft,
                child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "コメント",
                      hintStyle:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 20.0),
                    ),
                    maxLength: 14,
                    maxLines: null,
                    style: TextStyle(fontSize: 20),
                    onChanged: (text) => setState(() {
                          _titleCompleted = text.isNotEmpty;
                          comment = _titleController.text.toString();
                        }))),
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
                              mainAxisAlignment:
                                  MainAxisAlignment.start,
                              children: <Widget>[
                                ListTile(
                                    leading: Icon(Icons.info),
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
                child: Text("確定")),
          ),
        ],
      ),
    );
  }
}
