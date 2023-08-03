import 'package:flutter/material.dart';

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
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, 
                  children: [
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
                    print("タップ");
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
          )
        ],
      ),
    );
  }
}
