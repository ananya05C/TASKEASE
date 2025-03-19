import 'package:flutter/material.dart';
import 'dart:async';
import 'database_helper.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://media.istockphoto.com/id/1279896336/vector/yellow-check-mark-in-box-symbol.jpg?s=612x612&w=0&k=20&c=HUjKacHW7f2DC_OVzqaEjUXEcTbU4TlbMX4zF8ec2mk=', // Replace with your image URL
              height: 300,
              width: 300,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow[100]!),
            ),
            SizedBox(height: 20),
            Text(
              "Loading ...",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}


// To-Do List Screen
class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  void fetchTasks() async {
    List<Map<String, dynamic>> taskList = await dbHelper.getTasks();
    setState(() {
      tasks = taskList;
    });
  }

  void deleteTask(int id) async {
    await dbHelper.deleteTask(id);
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.yellow[100],
        title: Text('HOME',style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: tasks.isEmpty
          ? Center(child: Text("No tasks added yet!"))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Card(color: Colors.yellow[200],
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(tasks[index]['task'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(tasks[index]['description'] ?? "No description"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.black45),
                    onPressed: () async {
                      bool taskUpdated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(
                            id: tasks[index]['id'],
                            task: tasks[index]['task'],
                            description: tasks[index]['description'],
                          ),
                        ),
                      );
                      if (taskUpdated == true) {
                        fetchTasks();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteTask(tasks[index]['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool newTaskAdded = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (newTaskAdded == true) {
            fetchTasks();
          }
        },
        backgroundColor: Colors.yellow[300], // Set background color to yellow
        shape: CircleBorder(), // Ensures the button remains circular
        child: Icon(Icons.add, color: Colors.black), // Change icon color for contrast
      ),

    );
  }
}

// Add Task Screen
class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  TextEditingController taskController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void saveTask() async {
    if (taskController.text.isNotEmpty) {
      await dbHelper.insertTask(taskController.text, descriptionController.text);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Task"),backgroundColor: Colors.yellow[200],),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(hintText: "Enter task", border: OutlineInputBorder(),hintStyle: TextStyle(color: Colors.grey),),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: "Enter description", border: OutlineInputBorder(),hintStyle: TextStyle(color: Colors.grey),),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveTask,
              child: Text("Save "),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[300], // Change button color
                foregroundColor: Colors.grey, // Change text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Edit Task Screen
class EditTaskScreen extends StatefulWidget {
  final int id;
  final String task;
  final String description;

  EditTaskScreen({required this.id, required this.task, required this.description});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  late TextEditingController taskController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    taskController = TextEditingController(text: widget.task);
    descriptionController = TextEditingController(text: widget.description);
  }

  void updateTask() async {
    if (taskController.text.isNotEmpty) {
      await dbHelper.updateTask(widget.id, taskController.text, descriptionController.text);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Task"),backgroundColor: Colors.yellow[200],),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(hintText: "Enter task", border: OutlineInputBorder(),hintStyle: TextStyle(color: Colors.grey),),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: "Enter description", border: OutlineInputBorder(),hintStyle: TextStyle(color: Colors.grey)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateTask,
              child: Text("Update "),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[300], // Change button color
                foregroundColor: Colors.black45, // Change text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
