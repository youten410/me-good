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

    final _collectionRef = FirebaseFirestore.instance.collection("UserGoodCounts");
    fetchCommentsByDate().then((fetchedData) {
      setState(() {
        _eventsList = fetchedData;
      });
    });
  }

  Future<Map<DateTime, List<dynamic>>> fetchCommentsByDate() async {
    Map<DateTime, List<dynamic>> dateCommentMap = {};

    final _collectionRef = FirebaseFirestore.instance.collection("UserGoodCounts");

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
    String displayComment = dayEvents.isNotEmpty ? dayEvents[0].toString() : 'No Events';
    String displayGoodCount = dayEvents.isNotEmpty ? dayEvents[1].toString() : 'No Count';

    return Column(
      children: [
        TableCalendar(
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
            formatButtonVisible: false,
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
        ),
        ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text('コメント: $displayComment \nいいね数: $displayGoodCount')
            ),
          ],
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
          color: Colors.red[300],
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
