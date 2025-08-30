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

enum Filtertype { all, starred, date }

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  DateTime? pickeddate;
  TimeOfDay? pickedtime;
  Filtertype selectedFileter = Filtertype.all;
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
          PopupMenuButton<Filtertype>(
            icon: Icon(Icons.filter_list, color: Customcolors.yellow),
            onSelected: (Filtertype value) {
              setState(() {
                selectedFileter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: Filtertype.all, child: Text("All")),

              PopupMenuItem(value: Filtertype.date, child: Text("Date")),
              PopupMenuItem(value: Filtertype.starred, child: Text("Starred")),
            ],
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
          List<Task> filteredTasks = currentPage.tasks;
          if (selectedFileter == Filtertype.starred) {
            filteredTasks = filteredTasks
                .where((task) => task.isStarred == true)
                .toList();
          }
          if (selectedFileter == Filtertype.date) {
            filteredTasks = filteredTasks
                .where((task) => task.date != null)
                .toList();

            if (selectedFileter == Filtertype.date) {
              filteredTasks = filteredTasks
                  .where((task) => task.date != null)
                  .toList();

              filteredTasks.sort((a, b) {
                return a.date!.compareTo(b.date!);
              });

              if (filteredTasks.isEmpty) {
                return const Center(child: Text("No tasks match this filter"));
              }
            }

            if (filteredTasks.isEmpty) {
              return const Center(child: Text("No tasks match this filter"));
            }
          }

          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return Card(
                child: ListTile(
                  leading: Checkbox(
                    checkColor: Customcolors.lightBlue,
                    activeColor: Customcolors.yellow,
                    value: task.isCompleted ?? false,
                  onChanged: (value) {
  setState(() {
    final originalIndex = currentPage.tasks.indexOf(task);
    if (originalIndex != -1) {
      // 1. Update the task's completion status.
      final updatedTask = task;
      updatedTask.isCompleted = value ?? false;

      // 2. Remove the task from its original position.
      currentPage.tasks.removeAt(originalIndex);

      // 3. Conditionally add the task to the beginning or end of the list.
      if (updatedTask.isCompleted!) {
        // If checked, add to the end of the list.
        currentPage.tasks.add(updatedTask);
      } else {
        // If unchecked, add to the beginning of the list.
        currentPage.tasks.insert(0, updatedTask);
      }

      // 4. Save the changes to the Hive box.
      currentPage.save();
    }
  });
},
                  ),
                  title: Text(
                    task.title == "" ? "untitled" : task.title!,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.date != null
                            ? "Due date: ${task.date!.day}/${task.date!.month}/${task.date!.year}"
                            : "No due date set",
                        style: GoogleFonts.lato(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        task.time != null
                            ? "Due time: ${task.time}"
                            : "Schedueled time: ${TimeOfDay.now().format(context)}",
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
                          task.isStarred == true
                              ? Icons.star
                              : Icons.star_border,
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
                            final originalIndex = currentPage.tasks.indexOf(
                              task,
                            );
                            if (originalIndex != -1) {
                              currentPage.tasks.removeAt(originalIndex);
                              currentPage.save();
                            }
                          });
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          pickeddate = null;
                          pickedtime = null;
                          TextEditingController editcontroller =
                              TextEditingController(text: task.title);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setStateDialog) {
                                  return AlertDialog(
                                    title: Text('Edit Task'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: editcontroller,
                                          autofocus: true,
                                          decoration: InputDecoration(
                                            hintText: 'Enter task title',
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            IconButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Customcolors.lightBlue,
                                              ),
                                              onPressed: () async {
                                                DateTime? date =
                                                    await datePicker(context);
                                                setStateDialog(() {
                                                  if (date != null) {
                                                    pickeddate = date;
                                                  }
                                                });
                                              },
                                              icon: Icon(Icons.calendar_month),
                                            ),
                                            SizedBox(width: 10),
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
                                            IconButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Customcolors.lightBlue,
                                              ),
                                              onPressed: () async {
                                                TimeOfDay? time =
                                                    await timePicker(context);
                                                setStateDialog(() {
                                                  if (time != null) {
                                                    pickedtime = time;
                                                  }
                                                });
                                              },
                                              icon: Icon(Icons.access_time),
                                            ),
                                            SizedBox(width: 10),
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
                                          setState(() {
                                            final originalIndex = currentPage
                                                .tasks
                                                .indexOf(task);
                                            if (originalIndex != -1) {
                                              currentPage
                                                  .tasks[originalIndex] = Task(
                                                title: editcontroller.text,
                                                isCompleted: task.isCompleted,
                                                isStarred: task.isStarred,
                                                date: pickeddate,
                                                time: pickedtime?.format(
                                                  context,
                                                ),
                                              );
                                              currentPage.save();
                                            }
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.edit, color: Colors.lightGreen),
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
                pickeddate = null;
                pickedtime = null;
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
                                Taskpage(
                                  title: tasktitleController.text == ""
                                      ? "Untitled"
                                      : tasktitleController.text,
                                ),
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
          pickeddate = null;
          pickedtime = null;
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
                            IconButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Customcolors.lightBlue,
                              ),
                              onPressed: () async {
                                DateTime? date = await datePicker(context);
                                setStateDialog(() {
                                  if (date != null) {
                                    pickeddate = date;
                                  }
                                });
                              },
                              icon: Icon(Icons.calendar_month),
                            ),
                            SizedBox(width: 10),
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
                            IconButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Customcolors.lightBlue,
                              ),
                              onPressed: () async {
                                TimeOfDay? time = await timePicker(context);
                                setStateDialog(() {
                                  if (time != null) {
                                    pickedtime = time;
                                  }
                                });
                              },
                              icon: Icon(Icons.access_time),
                            ),
                            SizedBox(width: 10),
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
                            currentPage.tasks = [newTask, ...currentPage.tasks];
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
