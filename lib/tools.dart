import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'package:hive/hive.dart';


class Customcolors {
  static const Color darkBlue = Color(0xFF154D71);
  static const Color blue = Color(0xFF1C6EA4);
  static const Color lightBlue = Color(0xFF33A1E0);
  static const Color yellow = Color(0xFFFFF9AF);
}

Future<DateTime?> datePicker(BuildContext context) async {
  return await showDatePicker(
    context: context,
    firstDate: DateTime(2024),
    initialDate: DateTime.now(),
    lastDate: DateTime(2100),
  );
}

Future<TimeOfDay?> timePicker(BuildContext context) async {
  return await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    barrierColor: Customcolors.blue,
  );
}
String formatToISD(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat.jm().format(dt); // e.g. 6:45 PM
}

void printAllTasks(Box<Taskpage> box) {
  for (int i = 0; i < box.length; i++) {
    final taskPage = box.getAt(i);

    if (taskPage != null) {
      print("📄 TaskPage: ${taskPage.title}");

      
    }
  }
}
