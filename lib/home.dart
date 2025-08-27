import 'package:flutter/material.dart';
import 'package:todo/models.dart';
import 'tools.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  DateTime? pickeddate;
  TimeOfDay? pickedtime;
  var box = Hive.box<Taskpage>("pages");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Customcolors.darkBlue,
        title: const Text(
          'My Tasks',
          style: TextStyle(
            color: Customcolors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_alt, color: Customcolors.yellow),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Taskpage> taskBox, _) {
          if (taskBox.isEmpty) {
            return const Center(child: Text("No pages yet"));
          }

          final currentPage = taskBox.getAt(selectedIndex);
          if (currentPage == null || currentPage.tasks.isEmpty) {
            return const Center(child: Text("No tasks yet"));
          }

          return ListView.builder(
            itemCount: currentPage.tasks.length,
            itemBuilder: (context, index) {
              final task = currentPage.tasks[index];
              return Card(
                child: ListTile(
                  leading: Checkbox(checkColor: Customcolors.lightBlue,activeColor: Customcolors.yellow,
                    value: task.isCompleted ?? false,
                    onChanged: (value) {
                      setState(() {
                        task.isCompleted = value ?? false;
                        currentPage.save(); // persist
                      });
                    },
                   
                              
                
                        
                    ),
                    title: Text(
                      task.title=="" ? "untitled":task.title!,
                      style: GoogleFonts.lato(
                        decoration: task.isCompleted == true
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Customcolors.blue,
                      ),
                    ),
                    subtitle: Column(
                      children: [
                        
                        Text(
                          task.date != null
                              ? "Due date: ${task.date!.day}/${task.date!.month}/${task.date!.year}"
                              : "Task Schedueled date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                          style: GoogleFonts.lato(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          task.time != null
                              ? "Due time: ${task.time}"
                              : "Task Schedueled date: ${TimeOfDay.now().format(context)}",
                          style: GoogleFonts.lato(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                   
                    
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            task.isStarred == true ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              task.isStarred = !(task.isStarred ?? false);
                              currentPage.save();
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.blueGrey),
                          onPressed: () {
                            setState(() {
                              currentPage.tasks.removeAt(index);
                              currentPage.save();
                            });
                           
                          },
                        ),
                      ],
                    ),
                  
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Customcolors.darkBlue,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(box.length, (index) {
                    final bool isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 18,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Customcolors.lightBlue
                              : Customcolors.yellow,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          box.getAt(index)!.title ?? "untitled",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white
                                : Customcolors.darkBlue,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                TextEditingController tasktitleController =
                    TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Add New Taskpage'),
                      content: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Enter page title',
                        ),
                        controller: tasktitleController,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              box.add(
                                Taskpage(title: tasktitleController.text=="" ? "Untitled":tasktitleController.text),
                              );
                            });
                            Navigator.of(context).pop();
                          },

                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.add_circle, color: Customcolors.yellow),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController taskscontroller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setStateDialog) {
                  return AlertDialog(
                    title: Text('Add  Task'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextField(
                          controller: taskscontroller,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Enter task title',
                          ),
                          //controller: tasktitleController,
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            IconButton(style: ElevatedButton.styleFrom(backgroundColor: Customcolors.lightBlue),
                              onPressed: () async {
                                DateTime? date = await datePicker(context);
                                setStateDialog(() {
                                  if (date != null) {
                                    pickeddate = date;
                                  }
                                });
                              },
                               icon:Icon(Icons.calendar_month,)
                               
                            ),SizedBox(width: 10),
                            Text(
                                pickeddate == null
                                    ? "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
                                    : "${pickeddate!.day}/${pickeddate!.month}/${pickeddate!.year}",
                              ),
                          ],
                        ),
                        SizedBox(height: 10),

                        
                        Row(
                          children: [
                            IconButton(style: ElevatedButton.styleFrom(backgroundColor: Customcolors.lightBlue),
                              onPressed: () async {
                                TimeOfDay? time = await timePicker(context);
                                setStateDialog(() {
                                  if (time != null) {
                                    pickedtime = time;
                                  }
                                });
                              },
                              icon: Icon(Icons.access_time)
                              
                            ),SizedBox(width: 10),
                            Text(
                                pickedtime == null
                                    ? "${TimeOfDay.now().format(context)}"
                                    : formatToISD(
                                        pickedtime!,
                                      ), // convert to 12hr format only for display
                              ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          print(taskscontroller.text);
                          setState(() {
                            Taskpage currentPage = box.getAt(selectedIndex)!;
                            Task newTask = Task(
                              title: taskscontroller.text,
                              isCompleted: false,
                              isStarred: false,
                              date: pickeddate,
                              time: pickedtime?.format(context),
                            );
                            currentPage.tasks = [...currentPage.tasks, newTask];
                            currentPage.save();
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        backgroundColor: Customcolors.yellow,

        child: Icon(Icons.add),
      ),
    );
  }
}
