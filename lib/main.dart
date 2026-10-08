import 'package:flutter/material.dart';
import 'package:yet_another_todo_list_app/views/settings.dart';

void main() {
  runApp(const MainApp());
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
  void openSettings() => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SettingsView()),
  );

  void add(BuildContext context) => showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text("Add Todo"),
      children: [
        const Text("Placeholder"),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: openSettings,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Icon(Icons.settings),
                  ),
                ),
              ]
            ),
            Spacer(),
            Text("Todo List"),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => add(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white
                    ),
                  ),
                ),
              ]
            ),
          ]
        )
      )
    );
  }
}