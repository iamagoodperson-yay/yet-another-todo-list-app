import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  final bool autoDeleteCompleted;
  final bool showImportance;
  final bool showAsTimeToDue;
  final bool uwuifier;

  final String categorisationMode;
  final void Function() categorisationModeCallback;
  final ThemeMode themeMode;
  final void Function(ThemeMode) themeModeCallback;
  final bool puzzleMode;
  final void Function() puzzleModeCallback;

  const SettingsView({
    super.key,
    required this.autoDeleteCompleted,
    required this.showImportance,
    required this.showAsTimeToDue,
    required this.uwuifier,
    required this.categorisationMode,
    required this.categorisationModeCallback,
    required this.themeMode,
    required this.themeModeCallback,
    required this.puzzleMode,
    required this.puzzleModeCallback,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late bool autoDeleteCompleted;
  late bool showImportance;
  late bool showAsTimeToDue;
  late bool uwuifier;

  late String categorisationMode;
  late void Function() categorisationModeCallback;
  late ThemeMode themeMode;
  late void Function(ThemeMode) themeModeCallback;
  late bool puzzleMode;
  late void Function() puzzleModeCallback;

  late final double _width = MediaQuery.of(context).size.width;

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoDeleteCompleted', autoDeleteCompleted);
    await prefs.setBool('showImportance', showImportance);
    await prefs.setBool('showAsTimeToDue', showAsTimeToDue);
    await prefs.setBool('uwuifier', uwuifier);
    await prefs.setString('categorisationMode', categorisationMode);
    await prefs.setString('themeMode', themeMode.name);
  }

  void closeSettings() {
    Navigator.pop(context, {
      'autoDeleteCompleted': autoDeleteCompleted,
      'showImportance': showImportance,
      'showAsTimeToDue': showAsTimeToDue,
      'uwuifier': uwuifier,
      'categorisationMode': categorisationMode,
      'themeMode': themeMode,
      'puzzleMode': puzzleMode,
    });
  }

  void puzzleDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hmmm...'),
      content: const Text(
        'What did this do? This changed nothing ⁉️',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();

    autoDeleteCompleted = widget.autoDeleteCompleted;
    showImportance = widget.showImportance;
    showAsTimeToDue = widget.showAsTimeToDue;
    uwuifier = widget.uwuifier;
    categorisationMode = widget.categorisationMode;
    categorisationModeCallback = widget.categorisationModeCallback;
    themeMode = widget.themeMode;
    themeModeCallback = widget.themeModeCallback;
    puzzleMode = widget.puzzleMode;
    puzzleModeCallback = widget.puzzleModeCallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
                onPressed: closeSettings,
                child: const Icon(Icons.arrow_back),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _width * 0.1),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    SwitchListTile(
                      title: Text(
                        uwuifier
                            ? 'Auto-dewete compweted todos :3'
                            : 'Auto-delete completed todos',
                      ),
                      value: autoDeleteCompleted,
                      onChanged: (value) {
                        setState(() {
                          autoDeleteCompleted = value;
                        });
                        saveSettings();
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        uwuifier ? 'Show impowtance :3' : 'Show importance',
                      ),
                      value: showImportance,
                      onChanged: (value) {
                        setState(() {
                          showImportance = value;
                        });
                        saveSettings();
                      },
                    ),
                    SwitchListTile(
                      title: Text(uwuifier ? 'Show due as date :3' : 'Show due as date'),
                      value: showAsTimeToDue,
                      onChanged: (value) {
                        setState(() {
                          showAsTimeToDue = value;
                        });
                        saveSettings();
                      },
                    ),
                    SwitchListTile(
                      title: Text(uwuifier ? 'Uwuifier mode :3' : 'Uwuifier mode'),
                      value: uwuifier,
                      onChanged: (value) {
                        setState(() {
                          uwuifier = value;
                        });
                        saveSettings();
                      },
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: categorisationMode,
                      decoration: InputDecoration(
                        labelText: uwuifier ? 'Sowting Mode :3' : 'Sorting Mode',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'importance',
                          child: Text(uwuifier ? 'Impowtance (=ↀωↀ=)✧' : 'Importance'),
                        ),
                        DropdownMenuItem(
                          value: 'dueDate',
                          child: Text(uwuifier ? 'Due date (⁄ ⁄O⁄ω⁄O⁄ ⁄)' : 'Due date'),
                        ),
                        DropdownMenuItem(
                          value: 'alphabetical',
                          child: Text(uwuifier ? 'Awpabeticaw ( =ω=)..' : 'Alphabetical'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            categorisationMode = value;
                            categorisationModeCallback();
                          });
                          saveSettings();
                        }
                      },
                    ),
                    DropdownButtonFormField<ThemeMode>(
                      initialValue: themeMode,
                      decoration: InputDecoration(
                        labelText: uwuifier ? 'Theme :3' : 'Theme',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Row(
                            children: [
                              const Icon(Icons.light_mode),
                              const SizedBox(width: 8),
                              Text(uwuifier ? 'Light (owo)' : 'Light'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Row(
                            children: [
                              const Icon(Icons.dark_mode),
                              const SizedBox(width: 8),
                              Text(uwuifier ? 'Dark (–w–)' : 'Dark'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Row(
                            children: [
                              const Icon(Icons.computer),
                              const SizedBox(width: 8),
                              Text(uwuifier ? 'System setting (>w<)' : 'System setting'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            themeMode = value;
                            themeModeCallback(value);
                          });
                          saveSettings();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    puzzleMode = true;
                    showImportance = true;
                    puzzleModeCallback();
                  });
                  puzzleDialog(context);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                child: Text(
                  'I wonder what this button does...',
                  style: TextStyle(
                    fontSize: 10,
                    color: puzzleMode ? Colors.red : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}