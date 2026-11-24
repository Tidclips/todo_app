import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';

class TasksPage extends StatefulWidget {

  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  double? _deviceHeight;
  String? content;
  Box? _box;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight! * 0.1,
        title: const Text("Daily Planner"),
      ),
      body: _tasksWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: displayTaskPop,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _todoList() {
    List tasks = _box!.values.toList();
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "No tasks yet! Tap + to add one.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = Task.fromMap(tasks[index]);
        return ListTile(
          title: Text(
            task.todo,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(task.timeStamp.toString()),
          trailing: task.done
              ? const Icon(
                  Icons.check_box_outlined,
                  color: Colors.green,
                )
              : const Icon(Icons.check_box_outline_blank),
          onTap: () {
            task.done = !task.done;
            _box!.putAt(index, task.toMap());
            setState(() {});
          },
          onLongPress: () {
            _box!.deleteAt(index);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _tasksWidget() {
    return FutureBuilder(
      future: Hive.openBox("tasks"),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _box = snapshot.data;
          return _todoList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void displayTaskPop() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Add a ToDo"),
          content: TextField(
            autofocus: true,
            onSubmitted: (value) {
              if (content != null && content!.trim().isNotEmpty) {
                var task = Task(
                  todo: content!.trim(),
                  timeStamp: DateTime.now(),
                  done: false,
                );
                _box!.add(task.toMap());
                content = null;
                setState(() {});
                Navigator.pop(dialogContext);
              }
            },
            onChanged: (value) {
              content = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                content = null;
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (content != null && content!.trim().isNotEmpty) {
                  var task = Task(
                    todo: content!.trim(),
                    timeStamp: DateTime.now(),
                    done: false,
                  );
                  _box!.add(task.toMap());
                  content = null;
                  setState(() {});
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
