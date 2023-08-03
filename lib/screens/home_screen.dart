import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'),
      ),body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('今日の自分にGood!'),
          ),
          Center(
            child: IconButton(
              icon: Icon(Icons.thumb_up), 
              iconSize: 200,
              color: const Color.fromARGB(255, 255, 207, 34),
              onPressed: () {  
                print('tpped');
              },
            ),
          ),
        ],
      ),
    );
  }
}