import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo/models.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TaskpageAdapter());
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox('taskbox');
  var box = await Hive.openBox<Taskpage>("pages");
  if (box.isEmpty) {
    box.add(Taskpage(title: "default"));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}
