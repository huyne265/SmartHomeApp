import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'alert.dart';

class ScheduleApp extends StatefulWidget {
  final List<Map<String, dynamic>> schedules;

  const ScheduleApp({super.key, required this.schedules});

  @override
  _ScheduleAppState createState() => _ScheduleAppState();
}

class _ScheduleAppState extends State<ScheduleApp> {
  final FirebaseAlertService _firebaseAlertService = FirebaseAlertService();
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  late List<Map<String, dynamic>> schedules;
  List<Timer?> scheduledTimers = [];

  @override
  void initState() {
    super.initState();
    _firebaseAlertService.listenForFireValue(context);

    schedules = widget.schedules;
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
      String relayKey =
          schedule['relay'] == 5 ? 'Relay5' : 'Relay${schedule['relay']}';
      _toggleRelay(relayKey, schedule['action']);
      if (schedule['repeatDaily'] == true) {
        schedule['enabled'] = true; // Reset enabled
        _scheduleRelayAction(schedule); // Schedule for the next day
      } else {
        setState(() {
          schedule['enabled'] = false;
        });
      }
    });

    scheduledTimers.add(timer);
  }

  void _toggleRelay(String relayKey, bool status) {
    databaseReference.child('Relay').update({
      relayKey: status ? 1 : 0,
    });

    databaseReference.child('Relay/Mode').set('Manual');
  }

  void _editSchedule(int index) {
    final schedule = schedules[index];
    _showScheduleDialog(context, schedule: schedule, index: index);
  }

  void _showScheduleDialog(
    BuildContext context, {
    Map<String, dynamic>? schedule,
    int? index,
  }) async {
    int? selectedRelay = schedule?['relay'];
    TimeOfDay? selectedTime = schedule?['time'];
    bool? selectedAction = schedule?['action'];
    bool repeatDaily = schedule?['repeatDaily'] ?? false;
    bool isEditing = schedule != null;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // setDialogState được cung cấp bởi StatefulBuilder
            return AlertDialog(
              title: Text(isEditing ? "Edit Schedule" : "Add Schedule"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Relay Selector
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: "Select Relay",
                            labelStyle: TextStyle(
                              color: Color(0xFF2b669c),
                            )),
                        value: selectedRelay,
                        items: [1, 2, 3, 4]
                            .map((relay) => DropdownMenuItem(
                                  value: relay,
                                  child: Text(
                                    "Relay $relay",
                                    style: TextStyle(color: Color(0xFF021024)),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedRelay = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Time Picker
                    Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          selectedTime != null
                              ? "Time: ${selectedTime!.format(context)}"
                              : "Select Time",
                          style: TextStyle(color: Color(0xFF2b669c)),
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF052659),
                                    onPrimary: Color(0xFFc1e8ff),
                                    onSurface: Color(0xFF052659),
                                  ),
                                  timePickerTheme: TimePickerThemeData(
                                    dayPeriodTextColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => states.contains(
                                                    MaterialState.selected)
                                                ? Color(0xFFc1e8ff)
                                                : Color(0xFF052659)),
                                    dayPeriodColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => states.contains(
                                                    MaterialState.selected)
                                                ? Color(0xFF052659)
                                                : Color(0xFFc1e8ff)),
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF052659),
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedTime = time;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedAction = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedAction == true
                                ? Color(0xFF052659)
                                : Color(0xFFc1e8ff),
                          ),
                          child: Text(
                            "ON",
                            style: TextStyle(
                              color: selectedAction == true
                                  ? Color(0xFFc1e8ff)
                                  : Color(0xFF052659),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedAction = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedAction == false
                                ? Color(0xFF052659)
                                : Color(0xFFc1e8ff),
                          ),
                          child: Text(
                            "OFF",
                            style: TextStyle(
                              color: selectedAction == false
                                  ? Color(0xFFc1e8ff)
                                  : Color(0xFF052659),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Repeat Daily Option
                    CheckboxListTile(
                      title: const Text(
                        "Repeat Daily",
                        style: TextStyle(
                          color: Color(0xFF021024),
                        ),
                      ),
                      value: repeatDaily,
                      activeColor: Color(0xFF5483b3),
                      onChanged: (value) {
                        setDialogState(() {
                          repeatDaily = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF5483b3),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: selectedRelay != null &&
                          selectedTime != null &&
                          selectedAction != null
                      ? () {
                          setState(() {
                            final updatedSchedule = {
                              'relay': selectedRelay,
                              'time': selectedTime,
                              'action': selectedAction,
                              'enabled': true,
                              'repeatDaily': repeatDaily,
                            };

                            if (isEditing && index != null) {
                              scheduledTimers[index]?.cancel();
                              schedules[index] = updatedSchedule;
                              _scheduleRelayAction(updatedSchedule);
                            } else {
                              schedules.add(updatedSchedule);
                              _scheduleRelayAction(updatedSchedule);
                            }

                            // Đồng bộ lịch trình lên Firebase mỗi khi thêm/sửa
                            _syncSchedulesToFirebase();
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(
                    isEditing ? "Update" : "Add",
                    style: TextStyle(
                      color: Color(0xFF5483b3),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    for (var timer in scheduledTimers) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(context),
        backgroundColor: Color(0xFFc1e8ff),
        child: const Icon(
          Icons.add_alarm_rounded,
          color: Color(0xFF021024),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFc1e8ff),
              Color(0xFF7da0ca),
              Color(0xFF5483b3),
              Color(0xFF2b669c),
              Color(0xFF052659),
              Color(0xFF021024),
            ],
          ),
        ),
        child: schedules.isEmpty
            ? const Center(
                child: Text(
                "No schedules added.",
                style: TextStyle(
                  color: Color(0xFFc1e8ff),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ))
            : ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return Dismissible(
                    key: Key(schedule.toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      setState(() {
                        scheduledTimers[index]?.cancel();
                        scheduledTimers.removeAt(index);
                        schedules.removeAt(index);

                        _syncSchedulesToFirebase();
                      });
                    },
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () => _editSchedule(index),
                        title: Text(
                          "Relay ${schedule['relay']} - ${schedule['action'] ? 'ON' : 'OFF'}",
                          style: TextStyle(
                            color: schedule['enabled']
                                ? Color(0xFF021024)
                                : Colors.grey,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Time: ${schedule['time'].format(context)}",
                          style: TextStyle(
                            color: schedule['enabled']
                                ? Color(0xFF2b669c)
                                : Colors.grey,
                          ),
                        ),
                        trailing: Switch(
                          value: schedule['enabled'],
                          onChanged: (value) {
                            setState(() {
                              schedule['enabled'] = value;
                              if (value) {
                                _scheduleRelayAction(schedule);
                              } else {
                                scheduledTimers[index]?.cancel();
                              }

                              _syncSchedulesToFirebase();
                            });
                          },
                          activeColor: Color(0xFF2b669c),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
