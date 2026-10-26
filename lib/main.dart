import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yet_another_todo_list_app/views/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class Todo {
  String title;
  bool completed;
  int importance; // 0 highest, 4 lowest
  DateTime? dueDate;

  Todo({required this.title, this.completed = false, this.importance = 4, this.dueDate});
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode themeMode = ThemeMode.system;

  void themeModeCallback(ThemeMode newThemeMode) {
    setState(() {
      themeMode = newThemeMode;
    });
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final themeModeString = prefs.getString('themeMode') ?? 'system';
      switch (themeModeString) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        default:
          themeMode = ThemeMode.system;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

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
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          primary: Colors.lightBlue,
          secondary: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeMode,
      home: TodoView(
        themeMode: themeMode,
        themeModeCallback: themeModeCallback,
      ),
    );
  }
}

class TodoView extends StatefulWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) themeModeCallback;

  const TodoView({super.key, required this.themeMode, required this.themeModeCallback});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  bool autoDeleteCompleted = true;
  bool showImportance = true;
  bool showAsTimeToDue = true;
  bool uwuifier = true;
  String categorisationMode = 'importance';
  bool puzzleMode = false;

  late final TextEditingController _titleController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final double _width = MediaQuery.of(context).size.width;
  late final double _height = MediaQuery.of(context).size.height;

  int _tempImportance = 4;
  DateTime? _selectedDate;

  late Map<int, MaterialColor> importanceOptions;
  List<Todo> todos = [];

  Future<void> openSettings() async { // opens settings view and updates settings on return
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsView(
          autoDeleteCompleted: autoDeleteCompleted,
          showImportance: showImportance,
          showAsTimeToDue: showAsTimeToDue,
          uwuifier: uwuifier,
          categorisationMode: categorisationMode,
          categorisationModeCallback: () => setState(() => _sortTodos()),
          themeMode: widget.themeMode,
          themeModeCallback: widget.themeModeCallback,
          puzzleMode: puzzleMode,
          puzzleModeCallback: () => puzzleModeCallback(),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        autoDeleteCompleted = result['autoDeleteCompleted']!;
        showImportance = result['showImportance']!;
        showAsTimeToDue = result['showAsTimeToDue']!;
        uwuifier = result['uwuifier']!;
        categorisationMode = result['categorisationMode']!;
        puzzleMode = result['puzzleMode']!;
      });
    }
  }

  void addTodo(BuildContext context) { //adds todo, uwuifies if uwuifier is true
    String title = _titleController.text.trim();
    int importance = _tempImportance;
    DateTime? dueDate = _selectedDate;
    bool puzzleSolved = false;
    if (puzzleMode) {
      if (title.contains('write') && title.contains('paper')) {
        if (importance <= 1) {
          if (dueDate != null && dueDate.isBefore(DateTime.now().add(const Duration(days: 2))) 
                && dueDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
            puzzleSolved = true;
          }
        }
      }
    }
    if (uwuifier) {
      var endings = [
        'uwu',
        'owo',
        '>w<',
        '–w–',
        '(｡>﹏<｡)',
        '( =ω=)..nyaa',
        '(=ↀωↀ=)✧',
        '(* ^ ω ^)',
        '(⁄ ⁄O⁄ω⁄O⁄ ⁄)'
      ];
      for(var char in ['r', 'l']) {
        title = title.replaceAll(char, 'w');
      }
      for(var char in ['R', 'L']) {
        title = title.replaceAll(char, 'W');
      }
      title = '$title ${endings[Random().nextInt(endings.length)]}';
    }
    setState(() {
      todos.add(Todo(title: title, importance: importance, dueDate: dueDate));
      _sortTodos();
    });
    _saveTodos();
    _titleController.clear();
    _tempImportance = 4;
    _selectedDate = null;
    Navigator.pop(context);
    if (puzzleSolved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          puzzleSolvedDialog(this.context);
        }
      });
    }
  }

  void editTodo(int index) { // basically saves everything as everything
    String title = _titleController.text.trim();
    int importance = _tempImportance;
    DateTime? dueDate = _selectedDate;
    if (title.isNotEmpty) {
      setState(() {
        todos[index].title = title;
        todos[index].importance = importance;
        todos[index].dueDate = dueDate;
        _sortTodos();
      });
      _saveTodos();
      _titleController.clear();
      _tempImportance = 4;
      _selectedDate = null;
      Navigator.pop(context);
    }
  }

  void deleteTodo(Todo todo) {
    setState(() {
      todos.remove(todo);
    });
    _saveTodos();
  }

  void setTodoCompleted(Todo todo, bool completed) {
    setState(() {
      todo.completed = completed;
    });
    _saveTodos();
  }

  void puzzleModeCallback() {
    setState(() {
      puzzleMode = true;
      todos = [
        Todo(title: "I can't seem to remember what I was about to do..."),
        Todo(title: "I think it was something important..."),
        Todo(title: "like, very very important..."),
        Todo(title: "Maybe it was something I needed to do today..."),
        Todo(title: "Or tomorrow..."),
        Todo(title: "But definitely by tomorrow"),
        Todo(title: "I should probably 'write' it down somewhere..."),
        Todo(title: "like, on a piece of 'paper' or something..."),
        Todo(title: "Maybe that has something to do with it..."),
      ];
    });
  }

  void _sortTodos() {
    todos.sort((a, b) {
      if (categorisationMode == 'importance') {
        // sorts by due date (importance sorted in ListBuilder)
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;

        return a.dueDate!.compareTo(b.dueDate!);
      } else if (categorisationMode == 'dueDate') {
        // sorts by due date, then importnace
        if (a.dueDate == null && b.dueDate == null) {
            return a.importance.compareTo(b.importance);
        }
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        
        final dateComparison = a.dueDate!.compareTo(b.dueDate!);
        if (dateComparison == 0) {
          return a.importance.compareTo(b.importance);
        } else {
          return dateComparison;
        }
      } else if (categorisationMode == 'alphabetical') {
        // sorts by alphabetical order
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
      return 0;
    });
  }

  Future<DateTime?> selectDialogDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    return pickedDate;
  }

  void puzzleSolvedDialog(BuildContext context) => showDialog(
    context: context,
    useRootNavigator: true,
    builder: (context) => AlertDialog(
      title: const Text("Puzzle Solved!"),
      content: const Text("Congratulations! You've solved the puzzle!\nHere's a code for you that will definintely not have any importance whatsoever on future projects that I make: 427193"),
      actions: [
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );

  void addTodoDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(uwuifier ? "Add Todo >w<" : "Add Todo"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: uwuifier ? 'Todo titew ( =ω=):' : 'Todo title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return uwuifier ? 'Pwease entew some text' : 'Please enter some text';
                  }
                  return null;
                },
              ),
              if (showImportance)
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(uwuifier ? 'Impowtance owo:' : 'Importance:'),
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 32,
                                color: importanceOptions[index],
                              ),
                            ],
                          ),
                          selectedIcon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 32,
                                color: importanceOptions[index],
                              ),
                              Icon(Icons.check, size: 16, color: Colors.white),
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
                    ),
                  ],
                ),
              Wrap(
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? selected =  await selectDialogDate();
                      if (selected != null) {
                        setState(() {
                          _selectedDate = selected;
                        });
                      }
                    },
                    child: Text(
                      uwuifier
                          ? 'Sewect due date (⁄ ⁄O⁄ω⁄O⁄ ⁄)'
                          : 'Select due date',
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    _selectedDate == null
                        ? uwuifier
                            ? 'No due date sewected (｡>﹏<｡)'
                            : 'No due date selected'
                        : _selectedDate!.toLocal().toString().split(' ')[0],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          SimpleDialogOption(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                addTodo(context);
              }
            },
            child: Text(uwuifier ? 'Done (✿^‿^)' : 'Done'),
          ),
          SimpleDialogOption(
            onPressed: () {
              _titleController.clear();
              _tempImportance = 4;
              _selectedDate = null;
              Navigator.pop(context);
            },
            child: Text(uwuifier ? 'Cancew >.<' : 'Cancel'),
          ),
        ],
      ),
    ),
  );

  void editTodoDialog(BuildContext context, int index) {
    _titleController.text = todos[index].title;
    _tempImportance = todos[index].importance;
    _selectedDate = todos[index].dueDate;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(uwuifier ? 'Edit Todo >w<' : 'Edit Todo'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: uwuifier ? 'Todo titew ( =ω=):' : 'Todo title',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return uwuifier ? 'Pwease entew some text' : 'Please enter some text';
                    }
                    return null;
                  },
                ),
                if (showImportance)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(uwuifier ? 'Impowtance owo:' : 'Importance:'),
                      Wrap(
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 32,
                                  color: importanceOptions[index],
                                ),
                              ],
                            ),
                            selectedIcon: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 32,
                                  color: importanceOptions[index],
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
                      ),
                    ],
                  ),
                Wrap(
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? selected =  await selectDialogDate();
                        if (selected != null) {
                          setState(() {
                            _selectedDate = selected;
                          });
                        }
                      },
                      child: Text(
                        uwuifier
                            ? 'Sewect due date (⁄ ⁄O⁄ω⁄O⁄ ⁄)'
                            : 'Select due date',
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      _selectedDate == null
                          ? uwuifier
                              ? 'No due date sewected (｡>﹏<｡)'
                              : 'No due date selected'
                          : _selectedDate!.toLocal().toString().split(' ')[0],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            SimpleDialogOption(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  editTodo(index);
                }
              },
              child: Text(uwuifier ? 'Done (✿^‿^)' : 'Done'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _titleController.clear();
                Navigator.pop(context);
                _tempImportance = 4;
                _selectedDate = null;
              },
              child: Text(uwuifier ? 'Cancew >.<' : 'Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      autoDeleteCompleted = prefs.getBool('autoDeleteCompleted') ?? true;
      showImportance = prefs.getBool('showImportance') ?? true;
      uwuifier = prefs.getBool('uwuifier') ?? true;
      categorisationMode = prefs.getString('categorisationMode') ?? 'dueDate';

      final List<String> todoStrings = prefs.getStringList('todos') ?? [];
      todos = todoStrings.map((todoString) {
        final Map<String, dynamic> todoMap = jsonDecode(todoString);
        return Todo(
          title: todoMap['title'],
          completed: todoMap['completed'],
          importance: todoMap['importance'],
          dueDate: todoMap['dueDate'] != null ? DateTime.parse(todoMap['dueDate']) : null
        );
      }).toList();
    });
  }

  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todoStrings = todos.map((todo) {
      return jsonEncode({
        'title': todo.title,
        'completed': todo.completed,
        'importance': todo.importance,
        'dueDate': todo.dueDate?.toIso8601String(),
      });
    }).toList();
    await prefs.setStringList('todos', todoStrings);
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();

    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (uwuifier) {
      importanceOptions = {
        0 : Colors.pink,
        1: Colors.purple,
        2: Colors.deepPurple,
        3: Colors.indigo,
        4: Colors.blue,
      };
    } else {
      importanceOptions = {
        0 : Colors.red,
        1: Colors.orange,
        2: Colors.yellow,
        3: Colors.green,
        4: Colors.blue,
      };
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: todos.isEmpty ?
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        uwuifier ? "No todos yet (｡>﹏<｡)" : "No todos yet",
                        style: const TextStyle(fontSize: 24, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: _width > 700 ? 
                        _width * 0.1 : _width > 400 ? 
                        _width * 0.05 : 8,
                    vertical: _height * 0.075,
                  ).add(const EdgeInsets.symmetric(vertical: 16)),
                  child: showImportance && categorisationMode == 'importance'
                    ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: importanceOptions.length,
                      itemBuilder: (context, index) {
                        if (todos.where((todo) => todo.importance == index).isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 24,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      top: 4,
                                      bottom: 4,
                                      child: Container(
                                        width: 2,
                                        color: importanceOptions[index],
                                      ),
                                    ),
                                    Icon(
                                      Icons.circle,
                                      color: importanceOptions[index],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TodoListView(
                                  todos: todos
                                    .where((todo) => todo.importance == index)
                                    .toList(),
                                  autoDeleteCompleted: autoDeleteCompleted,
                                  showImportance: showImportance,
                                  showAsTimeToDue: showAsTimeToDue,
                                  categorisationMode: categorisationMode,
                                  importanceOptions: importanceOptions,
                                  editTodoDialog: (context, todo) =>
                                    editTodoDialog(context, todos.indexOf(todo)),
                                  deleteTodo: deleteTodo,
                                  setTodoCompleted: setTodoCompleted,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : TodoListView(
                    todos: todos,
                    autoDeleteCompleted: autoDeleteCompleted,
                    showImportance: showImportance,
                    showAsTimeToDue: showAsTimeToDue,
                    categorisationMode: categorisationMode,
                    importanceOptions: importanceOptions,
                    editTodoDialog: (context, todo) =>
                      editTodoDialog(context, todos.indexOf(todo)),
                    deleteTodo: deleteTodo,
                    setTodoCompleted: setTodoCompleted,
                  ),
                ),
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () => addTodoDialog(context),
                child: const Icon(Icons.add),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: openSettings,
                child: const Icon(Icons.settings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoListView extends StatelessWidget {
  final List<Todo> todos;
  final bool autoDeleteCompleted;
  final bool showImportance;
  final bool showAsTimeToDue;
  final String categorisationMode;
  final Map<int, MaterialColor> importanceOptions;

  final void Function(BuildContext, Todo) editTodoDialog;
  final void Function(Todo) deleteTodo;
  final void Function(Todo, bool) setTodoCompleted;

  const TodoListView({
    super.key,
    required this.todos,
    required this.autoDeleteCompleted,
    required this.showImportance,
    required this.showAsTimeToDue,
    required this.categorisationMode,
    required this.importanceOptions,
    required this.editTodoDialog,
    required this.deleteTodo,
    required this.setTodoCompleted,
  });

  String _showToDue(Todo todo) {
    Duration difference = todo.dueDate!.difference(DateTime.now());
    difference += const Duration(days: 1);
    if (difference.inDays == 0) {
      return 'today';
    }
    String timeString = 'in ';
    if (difference.inDays > 365) {
      difference.inDays ~/ 365 == 1
          ? timeString += '${difference.inDays ~/ 365} year '
          : timeString += '${difference.inDays ~/ 365} years ';
      difference -= Duration(days: (difference.inDays ~/ 365) * 365);
    }
    if (difference.inDays > 30) {
      difference.inDays ~/ 30 == 1
          ? timeString += '${difference.inDays ~/ 30} month '
          : timeString += '${difference.inDays ~/ 30} months ';
      difference -= Duration(days: (difference.inDays ~/ 30) * 30);
    }
    if (difference.inDays > 7) {
      difference.inDays ~/ 7 == 1
          ? timeString += '${difference.inDays ~/ 7} week '
          : timeString += '${difference.inDays ~/ 7} weeks ';
      difference -= Duration(days: (difference.inDays ~/ 7) * 7);
    }
    if (difference.inDays > 0) {
      difference.inDays == 1
          ? timeString += '${difference.inDays} day '
          : timeString += '${difference.inDays} days ';
      difference -= Duration(days: difference.inDays);
    }
    return timeString;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: todos.map((todo) {
        return AnimatedOpacity(
          key: ValueKey(todo),
          opacity: autoDeleteCompleted && todo.completed 
              ? 0.0 : todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1))) 
              ? 0.5 : 1.0,
          duration: const Duration(seconds: 3),
          onEnd: () {
            if (autoDeleteCompleted && todo.completed) {
              deleteTodo(todo);
            }
          },
          child: ListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: todo.completed,
                  onChanged: (value) {
                    if (value == null) return;
                    setTodoCompleted(todo, value);
                  },
                ),
                if (showImportance && categorisationMode != 'importance')
                  Icon(
                    Icons.circle,
                    color: importanceOptions[todo.importance],
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                todo.dueDate != null ? Text(
                  showAsTimeToDue ? 'Due ${_showToDue(todo)}' : 'Due: ${todo.dueDate!.toLocal().toString().split(' ')[0].replaceAll(RegExp(r'-'), '/')}',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )
                : const Text('No due date'),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    deleteTodo(todo);
                  },
                ),
              ],
            ),
            onTap: () => editTodoDialog(context, todo),
            tileColor: todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1))) ? Colors.grey.withValues(alpha: 0.2) : null
          ),
        );
      }).toList(),
    );
  }
}