import 'package:flutter/material.dart';
import 'package:yet_another_todo_list_app/views/settings.dart';

void main() {
  runApp(const MainApp());
}

class Todo {
  String title;
  bool completed;

  Todo({required this.title, this.completed = false});
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Yet Another Todo List App",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.green,
        ),
      ),
      home: const TodoView(
        autoDeleteCompleted: false,
        showImportance: true,
      ),
    );
  }
}

class TodoView extends StatefulWidget {
  final bool autoDeleteCompleted;
  final bool showImportance;

  const TodoView({super.key, required this.autoDeleteCompleted, required this.showImportance});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  late bool autoDeleteCompleted;
  late bool showImportance;

  late final double _width = MediaQuery.of(context).size.width;
  late final double _height = MediaQuery.of(context).size.height;
  late final TextEditingController _titleController;

  List<Todo> todos = [];

  Future<void> openSettings() async {
    final result = await Navigator.push<Map<String, bool>>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsView(
          autoDeleteCompleted: autoDeleteCompleted,
          showImportance: showImportance,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        autoDeleteCompleted = result['autoDeleteCompleted']!;
        showImportance = result['showImportance']!;
      });
    }
  }

  void addTodo(String title) {
    title.trim();
    if (title.isNotEmpty) {
      setState(() {
        todos.add(Todo(title: title));
      });
      _titleController.clear();
      Navigator.pop(context);
    }
  }

  void editTodo(int index, String title) {
    title.trim();
    if (title.isNotEmpty) {
      setState(() {
        todos[index].title = title;
      });
      _titleController.clear();
      Navigator.pop(context);
    }
  }

  void completeTodo(int index) {
    setState(() {
      todos[index].completed = true;
    });
  }

  void addTodoDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Add Todo"),
      content: TextField(
        controller: _titleController,
        onSubmitted: (value) {
          addTodo(value);
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Add todo',
        ),
      ),
      actions: [
        SimpleDialogOption(
          onPressed: () {
            addTodo(_titleController.text);
          },
          child: const Text('Done'),
        ),
        SimpleDialogOption(
          onPressed: () {
            _titleController.clear();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    ),
  );

  void editTodoDialog(BuildContext context, int index) {
    _titleController.text = todos[index].title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Todo"),
        content: TextField(
          controller: _titleController,
          onSubmitted: (value) {
            editTodo(index, value);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Edit todo',
          ),
        ),
        actions: [
          SimpleDialogOption(
            onPressed: () {
              editTodo(index, _titleController.text);
            },
            child: const Text('Done'),
          ),
          SimpleDialogOption(
            onPressed: () {
              _titleController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();

    autoDeleteCompleted = widget.autoDeleteCompleted;
    showImportance = widget.showImportance;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            todos.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No todos yet",
                          style: TextStyle(fontSize: 24, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _width * 0.1,
                      vertical: _height * 0.075,
                    ).add(EdgeInsets.symmetric(vertical: 16)),
                    child: ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        return AnimatedOpacity(
                          key: ValueKey(todos[index]),
                          opacity: autoDeleteCompleted && todos[index].completed ? 0.0 : 1.0,
                          duration: const Duration(seconds: 3),
                          onEnd: () {
                            if (autoDeleteCompleted && todos[index].completed) {
                              setState(() {
                                todos.remove(todos[index]);
                              });
                            }
                          },

                          child: ListTile(
                            title: Text(
                              todos[index].title,
                              style: TextStyle(
                                color: Colors.black,
                                decoration: todos[index].completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              ),
                            ),
                            leading: Checkbox(
                              value: todos[index].completed,
                              onChanged: (value) {
                                if (value == null) return;
                                value ? 
                                  completeTodo(index) : 
                                  setState(() {todos[index].completed = value;});
                              },
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  todos.removeAt(index);
                                });
                              },
                            ),
                            onTap: ()=> editTodoDialog(context, index),
                          ),
                        );
                      },
                    ),
                  ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () => addTodoDialog(context),
                child: Icon(Icons.add),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: openSettings,
                child: Icon(Icons.settings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
