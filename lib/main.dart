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
      home: const TodoView(),
    );
  }
}

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final TextEditingController _titleController = TextEditingController();
  late double _weight = MediaQuery.of(context).size.width;


  List<Todo> todos = [];

  void openSettings() => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SettingsView()),
  );

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

  void addShowDialog(BuildContext context) => showDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              todos.isEmpty ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No todos yet",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ) : Padding(
                padding: EdgeInsets.symmetric(horizontal: _weight * 0.1, vertical: 16),
                child: ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
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
                          setState(() {
                            todos[index].completed = value!;
                          });
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
                    );
                  },
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
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: () => addShowDialog(context),
                  child: Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
