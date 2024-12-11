import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class ScheduleApp extends StatefulWidget {
  final List<Map<String, dynamic>> schedules;

  const ScheduleApp({super.key, required this.schedules});

  @override
  _ScheduleAppState createState() => _ScheduleAppState();
}

class _ScheduleAppState extends State<ScheduleApp> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  late List<Map<String, dynamic>> schedules;
  List<Timer?> scheduledTimers = [];
  @override
  void initState() {
    super.initState();
    schedules = widget.schedules;
    _scheduleAllTimers();
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
      _toggleRelay('Relay${schedule['relay']}', schedule['action']);

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
      relayKey: status ? "1" : "0",
    });
  }

  @override
  void dispose() {
    for (var timer in scheduledTimers) {
      timer?.cancel();
    }
    super.dispose();
  }

  void _editSchedule(int index) {
    final schedule = schedules[index];
    _showScheduleDialog(context, schedule: schedule, index: index);
  }

  Future<void> _showScheduleDialog(
    BuildContext context, {
    Map<String, dynamic>? schedule,
    int? index,
  }) async {
    int? selectedRelay = schedule?['relay'];
    TimeOfDay? selectedTime = schedule?['time'];
    bool? selectedAction = schedule?['action'];
    bool repeatDaily = schedule?['repeatDaily'] ?? false; // Mặc định false
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
                        ),
                        value: selectedRelay,
                        items: [1, 2, 3, 4]
                            .map((relay) => DropdownMenuItem(
                                  value: relay,
                                  child: Text("Relay $relay"),
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
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
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
                                ? Colors.green
                                : Colors.grey,
                          ),
                          child: const Text(
                            "ON",
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
                                ? Colors.red
                                : Colors.grey,
                          ),
                          child: const Text("OFF"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Repeat Daily Option
                    CheckboxListTile(
                      title: const Text("Repeat Daily"),
                      value: repeatDaily,
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
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
                              // Cancel existing timer
                              scheduledTimers[index]?.cancel();

                              // Update existing schedule
                              schedules[index] = updatedSchedule;

                              // Reschedule the action
                              _scheduleRelayAction(updatedSchedule);
                            } else {
                              // Add new schedule
                              schedules.add(updatedSchedule);
                              _scheduleRelayAction(updatedSchedule);
                            }
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(isEditing ? "Update" : "Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(context),
        backgroundColor: Colors.grey,
        child: const Icon(
          Icons.add_alarm_rounded,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: schedules.isEmpty
          ? const Center(child: Text("No schedules added."))
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
                    });
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      onTap: () => _editSchedule(index),
                      title: Text(
                        "Relay ${schedule['relay']} - ${schedule['action'] ? 'ON' : 'OFF'}",
                        style: TextStyle(
                          color:
                              schedule['enabled'] ? Colors.black : Colors.grey,
                        ),
                      ),
                      subtitle: Text(
                        "Time: ${schedule['time'].format(context)}",
                        style: TextStyle(
                          color:
                              schedule['enabled'] ? Colors.blue : Colors.grey,
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
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
