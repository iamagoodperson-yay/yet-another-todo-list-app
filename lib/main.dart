import 'package:flutter/material.dart';
import 'package:yet_another_todo_list_app/views/settings.dart';

void main() {
  runApp(const MainApp());
}

class Todo {
  String title;
  bool completed;
  int importance; // 0 lowest, 4 highest

  Todo({required this.title, this.completed = false, this.importance = 1});
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
        autoDeleteCompleted: true,
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
  
  late final TextEditingController _titleController; // to be deprecated
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final double _width = MediaQuery.of(context).size.width;
  late final double _height = MediaQuery.of(context).size.height;

  int _tempImportance = 0;
  List<Todo> todos = [];
  Map<String, MaterialColor> importanceOptions = {
    '0' : Colors.blue,
    '1' : Colors.green,
    '2' : Colors.yellow,
    '3' : Colors.orange,
    '4' : Colors.red,
  };

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

  void addTodo(String title, int importance) {
    setState(() {
      todos.add(Todo(title: title, importance: importance));
    });
    _titleController.clear();
    Navigator.pop(context);
  }

  void editTodo(int index, String title, int importance) {
    title.trim();
    if (title.isNotEmpty) {
      setState(() {
        todos[index].title = title;
        todos[index].importance = importance;
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
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Add Todo"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'todo title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              if (showImportance) Row(
                children: [
                  const Text('Importance:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 32,
                              color: importanceOptions[index.toString()],
                            ),
                          ],
                        ),
                        selectedIcon: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 32,
                              color: importanceOptions[index.toString()],
                            ),
                            Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            _tempImportance = index;
                          });
                        },
                        isSelected: _tempImportance == index,
                      );
                    }),
                  )
                ]
              ),
            ],
          ),
        ),
        actions: [
          SimpleDialogOption(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                addTodo(_titleController.text, _tempImportance);
              }
            },
            child: const Text('Done'),
          ),
          SimpleDialogOption(
            onPressed: () {
              _titleController.clear();
              Navigator.pop(context);
              _tempImportance = 0;
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    ),
  );

  void editTodoDialog(BuildContext context, int index) {
    _titleController.text = todos[index].title;
    _tempImportance = todos[index].importance;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Todo"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'todo title',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                if (showImportance) Row(
                  children: [
                    const Text('Importance:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 32,
                                color: importanceOptions[index.toString()],
                              ),
                            ],
                          ),
                          selectedIcon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 32,
                                color: importanceOptions[index.toString()],
                              ),
                              Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          onPressed: () {
                            setState(() {
                              _tempImportance = index;
                            });
                          },
                          isSelected: _tempImportance == index,
                        );
                      }),
                    )
                  ]
                ),
              ],
            ),
          ),
          actions: [
            SimpleDialogOption(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  editTodo(index, _titleController.text, _tempImportance);
                }
              },
              child: const Text('Done'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _titleController.clear();
                Navigator.pop(context);
                _tempImportance = 0;
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
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
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: todos[index].completed,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    value ? 
                                    completeTodo(index) : 
                                    setState(() {todos[index].completed = value;});
                                  },
                                ),
                                if (showImportance) Icon(
                                  Icons.circle,
                                  color: importanceOptions[todos[index].importance.toString()],
                                ),
                              ]
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
