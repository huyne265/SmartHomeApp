import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:flutter/material.dart';

class RelayScheduleService {
  static final RelayScheduleService _instance =
      RelayScheduleService._internal();

  // Factory constructor to return the singleton instance
  factory RelayScheduleService() => _instance;

  // Private constructor
  RelayScheduleService._internal();

  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> schedules = [];
  List<Timer?> scheduledTimers = [];

  // Public method to load schedules from Firebase
  Future<void> loadSchedulesFromFirebase() async {
    try {
      DataSnapshot snapshot = await databaseReference.child('Schedules').get();

      if (snapshot.value != null) {
        List<dynamic> savedSchedules = snapshot.value as List<dynamic>;

        List<Map<String, dynamic>> formattedSchedules =
            savedSchedules.map((schedule) {
          List<String> timeParts = (schedule['time'] as String).split(':');
          return {
            'relay': schedule['relay'],
            'time': TimeOfDay(
                hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
            'action': schedule['action'],
            'enabled': schedule['enabled'],
            'repeatDaily': schedule['repeatDaily'] ?? false
          };
        }).toList();

        // Initialize schedules with the loaded data
        initializeSchedules(formattedSchedules);
      }
    } catch (e) {
      print('Error loading schedules: $e');
    }
  }

  void initializeSchedules(List<Map<String, dynamic>> initialSchedules) {
    schedules = initialSchedules;
    _syncSchedulesToFirebase();
    _scheduleAllTimers();
  }

  void _syncSchedulesToFirebase() {
    List<Map<String, dynamic>> firebaseSchedules = schedules.map((schedule) {
      return {
        'relay': schedule['relay'],
        'time': '${schedule['time'].hour}:${schedule['time'].minute}',
        'action': schedule['action'],
        'enabled': schedule['enabled'],
        'repeatDaily': schedule['repeatDaily'] ?? false
      };
    }).toList();

    databaseReference.child('Schedules').set(firebaseSchedules);
  }

  void _scheduleAllTimers() {
    for (var timer in scheduledTimers) {
      timer?.cancel();
    }
    scheduledTimers.clear();

    for (var schedule in schedules) {
      if (schedule['enabled']) {
        _scheduleRelayAction(schedule);
      }
    }
  }

  void _scheduleRelayAction(Map<String, dynamic> schedule) {
    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      schedule['time'].hour,
      schedule['time'].minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    Duration timeUntilActivation = scheduledTime.difference(now);

    Timer timer = Timer(timeUntilActivation, () {
      _toggleRelay('Relay${schedule['relay']}', schedule['action']);

      if (schedule['repeatDaily'] == true) {
        schedule['enabled'] = true;
        _scheduleRelayAction(schedule);
      } else {
        schedule['enabled'] = false;
      }

      _syncSchedulesToFirebase();
    });

    scheduledTimers.add(timer);
  }

  void _toggleRelay(String relayKey, bool status) {
    databaseReference.child('Relay').update({
      relayKey: status ? "1" : "0",
    });
  }

  void addSchedule(Map<String, dynamic> newSchedule) {
    schedules.add(newSchedule);
    _scheduleRelayAction(newSchedule);
    _syncSchedulesToFirebase();
  }

  void updateSchedule(int index, Map<String, dynamic> updatedSchedule) {
    scheduledTimers[index]?.cancel();

    schedules[index] = updatedSchedule;

    if (updatedSchedule['enabled']) {
      _scheduleRelayAction(updatedSchedule);
    }

    _syncSchedulesToFirebase();
  }

  void removeSchedule(int index) {
    scheduledTimers[index]?.cancel();

    schedules.removeAt(index);

    _syncSchedulesToFirebase();
  }

  void dispose() {
    for (var timer in scheduledTimers) {
      timer?.cancel();
    }
    scheduledTimers.clear();
  }
}
