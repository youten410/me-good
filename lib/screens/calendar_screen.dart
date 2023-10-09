import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart' show DeviceInfoPlugin;

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

  String? uid;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    _getDeviceId().then((deviceId) {
      uid = deviceId;

      final _collectionRef = FirebaseFirestore.instance.collection(uid!);
      fetchCommentsByDate().then((fetchedData) {
        setState(() {
          _eventsList = fetchedData;
        });
      });
    });
  }

  Future<String?> _getDeviceId() async {
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

  Future<Map<DateTime, List<dynamic>>> fetchCommentsByDate() async {
    Map<DateTime, List<dynamic>> dateCommentMap = {};

    final collectionRef = FirebaseFirestore.instance.collection(uid!);

    try {
      QuerySnapshot querySnapshot = await collectionRef.get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        String dateString = doc.id;
        DateTime parsedDate = DateTime.parse(dateString);
        dynamic comment = doc.get('comment');
        dynamic goodCount = doc.get('goodCount');
        dateCommentMap[parsedDate] = [comment, goodCount];
      }
      return dateCommentMap;
    } catch (e) {
      return dateCommentMap;
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    List getEventForDay(DateTime day) {
      return events[day] ?? [];
    }

    List dayEvents = getEventForDay(_selectedDay!);
    String displayComment =
        dayEvents.isNotEmpty ? dayEvents[0].toString() : '・コメントはありません。';
    String displayGoodCount =
        dayEvents.isNotEmpty ? dayEvents[1].toString() : '0';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          TableCalendar(
            locale: 'ja_JP',
            calendarStyle: const CalendarStyle(
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
            headerStyle: const HeaderStyle(
              titleCentered: true,
              titleTextStyle: TextStyle(
                  fontSize: 22,
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold),
              headerPadding: EdgeInsets.all(30),
              leftChevronVisible: false,
              rightChevronVisible: false,
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
            daysOfWeekHeight: 30,
            daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 20),
                weekendStyle: TextStyle(fontSize: 20)),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: 350,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(20),
              ),
              color: const HSLColor.fromAHSL(1.0, 33, 1.0, 0.85).toColor(),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Text(
                'いいね数❤️$displayGoodCount\n\n\コメント📝\n$displayComment',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    var goodCount = events.length > 1 ? events[1].toString() : "0";

    return Positioned(
      right: -4,
      bottom: 5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange[700],
        ),
        width: 20.0,
        height: 20.0,
        child: Center(
          child: Text(
            goodCount,
            style: const TextStyle().copyWith(
              color: Colors.white,
              fontSize: 10.0,
            ),
          ),
        ),
      ),
    );
  }
}
