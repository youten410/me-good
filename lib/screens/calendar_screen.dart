import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List> _eventsList = {};
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String? uid;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    user = _auth.currentUser;
    if (user != null) {
      uid = user!.uid;
    }

    final _collectionRef = FirebaseFirestore.instance.collection(uid!);
    fetchCommentsByDate().then((fetchedData) {
      setState(() {
        _eventsList = fetchedData;
      });
    });
  }

  Future<Map<DateTime, List<dynamic>>> fetchCommentsByDate() async {
    Map<DateTime, List<dynamic>> dateCommentMap = {};

    final _collectionRef = FirebaseFirestore.instance.collection(uid!);

    try {
      QuerySnapshot querySnapshot = await _collectionRef.get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        String dateString = doc.id;
        DateTime parsedDate = DateTime.parse(dateString);
        dynamic comment = doc.get('comment');
        dynamic goodCount = doc.get('goodCount');
        dateCommentMap[parsedDate] = [comment, goodCount];
      }
      return dateCommentMap;
    } catch (e) {
      print("Error fetching data: $e");
      return dateCommentMap;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    List getEventForDay(DateTime day) {
      return _events[day] ?? [];
    }

    List dayEvents = getEventForDay(_selectedDay!);
    String displayComment =
        dayEvents.isNotEmpty ? dayEvents[0].toString() : 'No Events';
    String displayGoodCount =
        dayEvents.isNotEmpty ? dayEvents[1].toString() : 'No Count';

    return Column(
      children: [
        TableCalendar(
          locale: 'ja_JP',
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(fontSize: 20),
            weekendTextStyle: TextStyle(fontSize: 20, color: Colors.red),
            selectedDecoration: BoxDecoration(
              color: Colors.orangeAccent,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color.fromARGB(255, 248, 155, 126),
              shape: BoxShape.circle,
            ),
          ),
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          eventLoader: getEventForDay,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return _buildEventsMarker(date, events);
              }
              return null;
            },
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: TextStyle(fontSize: 22, color: Colors.black),
            headerPadding: EdgeInsets.all(10),
            formatButtonVisible: false,
            leftChevronIcon: Icon(
              Icons.arrow_left,
              color: Colors.black,
              size: 40,
            ), // 左ボタン
            rightChevronIcon: Icon(
              Icons.arrow_right,
              color: Colors.black,
              size: 40,
            ), // 右ボタン
          ),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          daysOfWeekHeight: 30,
          daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 20),
              weekendStyle: TextStyle(fontSize: 20)),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text('いいね数 : $displayGoodCount\n★きろく★\n$displayComment'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
              bottom: Radius.circular(20),
            ),
            color: Colors.orange[100],
          ),
          height: 200,
          width: 350,
        )
      ],
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    var goodCount = events.length > 1 ? events[1].toString() : "0";

    return Positioned(
      right: 5,
      bottom: 5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange[700],
        ),
        width: 16.0,
        height: 16.0,
        child: Center(
          child: Text(
            goodCount,
            style: TextStyle().copyWith(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }
}
