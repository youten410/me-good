import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    final _collectionRef =
        FirebaseFirestore.instance.collection("UserGoodCounts");

    Future<Map<DateTime, List<dynamic>>> fetchCommentsByDate() async {
      Map<DateTime, List<dynamic>> dateCommentMap = {};

      try {
        QuerySnapshot querySnapshot = await _collectionRef.get();
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          String dateString = doc.id;
          DateTime parsedDate = DateTime.parse(dateString);
          dynamic comment = doc.get('comment');
          dateCommentMap[parsedDate] = [comment];
        }
        return dateCommentMap;
      } catch (e) {
        print("Error fetching data: $e");
        return dateCommentMap;
      }
    }

    fetchCommentsByDate().then((fetchedData) {
      setState(() {
        _eventsList = fetchedData;
      });
    });
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

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: DateTime.now(),
          eventLoader: getEventForDay,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
          ),
          selectedDayPredicate: (day) {
            //以下追記部分
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
        ),
        ListView(
          shrinkWrap: true,
          children: getEventForDay(_selectedDay!)
              .map((event) => ListTile(
                    title: Text(event.toString()),
                  ))
              .toList(),
        )
      ],
    );
  }
}
