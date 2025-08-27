import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part'models.g.dart';
@HiveType(typeId: 0)
class Taskpage extends HiveObject{
  @HiveField( 0)
  String? title;
  @HiveField(1)
  List<Task> tasks;
  Taskpage({required this.title, this.tasks=const[]});
  }
  @HiveType(typeId:1)
  class Task{
    @HiveField(0)
    String? title;
    @HiveField(1)
    bool? isCompleted;
    @HiveField(2)
    bool? isStarred;
    @HiveField(3)
    DateTime? date;
    @HiveField(4)
    String? time;
    Task({
      required this.title,
      this.isCompleted=false,
      this.isStarred=false,
      this.date,
      this.time,
    });
  }
