import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeTimeZone();
  runApp(TodoApp());
}

class TodoAp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Lis',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/zoro.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 20), // Add spacing above the tasks
              Container(
                color: Colors.white.withOpacity(0.7), // Add a semi-transparent white background
                padding: EdgeInsets.all(16),
                child: Text(
                  'Tasks:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: YourContentWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class YourContentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Your App Content',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Future<void> initializeTimeZone() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
}

class Todo {
  String task;
  DateTime? dueDate;
  bool isCompleted;

  Todo({
    required this.task,
    this.dueDate,
    this.isCompleted = false,
  });
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Todo> _tasks = [];
  TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
          if (payload != null) {
            int taskIndex = int.parse(payload);
          }
        });
  }

  Future<void> _scheduleNotification(
      String task, DateTime dueDateTime) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var scheduledNotificationDateTime = tz.TZDateTime.from(
      dueDateTime,
      tz.local,
    );

    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Task Due',
      'Task: $task is due!',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        //backgroundColor: Colors.lightGreen,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.lightGreen.withOpacity(0.7), // Lighter shade of blue
                Colors.lightBlue, // Original blue color
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _tasks.clear();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/zoro.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20), // Add padding around the tasks
        child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                _tasks[index].isCompleted
                    ? 'Done: ${_tasks[index].task}'
                    : _tasks[index].task,
                style: TextStyle(
                  decoration: _tasks[index].isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: _tasks[index].dueDate != null
                  ? Text(
                  'Due: ${DateFormat.yMd().add_jm().format(_tasks[index].dueDate!)}')
                  : null,
              trailing: Checkbox(
                value: _tasks[index].isCompleted,
                onChanged: (value) {
                  setState(() {
                    _tasks[index].isCompleted = value!;
                  });
                },
              ),
              onTap: () async {
                String editedTask = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Edit Task'),
                      content: TextFormField(
                        controller: TextEditingController(
                            text: _tasks[index].task),
                        autofocus: true,
                        onChanged: (value) {
                          _tasks[index].task = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter task',
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(_taskController.text);
                          },
                          child: Text('Save'),
                        ),
                      ],
                    );
                  },
                );
                if (editedTask != null) {
                  setState(() {
                    _tasks[index].task = editedTask;
                  });
                }
              },
              onLongPress: () {
                setState(() {
                  _tasks.removeAt(index);
                });
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );

          if (_selectedDate != null) {
            _selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
          }

          if (_selectedDate != null && _selectedTime != null) {
            DateTime dueDateTime = DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            );

            String newTask = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Add Task'),
                  content: TextFormField(
                    controller: _taskController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Enter task',
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(_taskController.text);
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
            if (newTask != null && newTask.isNotEmpty) {
              setState(() {
                _tasks.add(Todo(
                  task: newTask,
                  dueDate: dueDateTime,
                ));
                if (DateTime.now().isBefore(dueDateTime)) {
                  _scheduleNotification(newTask, dueDateTime);
                }
              });
            }
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
