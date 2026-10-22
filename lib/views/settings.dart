import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  final bool autoDeleteCompleted;
  final bool showImportance;
  final bool uwuifier;
  final ThemeMode themeMode;
  final void Function(ThemeMode) themeModeCallback;

  const SettingsView({
    super.key,
    required this.autoDeleteCompleted,
    required this.showImportance,
    required this.uwuifier,
    required this.themeMode,
    required this.themeModeCallback,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late bool autoDeleteCompleted;
  late bool showImportance;
  late bool uwuifier;
  late ThemeMode themeMode;
  late void Function(ThemeMode) themeModeCallback;

  late final double _width = MediaQuery.of(context).size.width;

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoDeleteCompleted', autoDeleteCompleted);
    await prefs.setBool('showImportance', showImportance);
    await prefs.setBool('uwuifier', uwuifier);
    await prefs.setString('themeMode', themeMode.name);
  }

  void closeSettings() {
    Navigator.pop(context, {
      'autoDeleteCompleted': autoDeleteCompleted,
      'showImportance': showImportance,
      'uwuifier': uwuifier,
      'themeMode': themeMode,
    });
  }

  @override
  void initState() {
    super.initState();

    autoDeleteCompleted = widget.autoDeleteCompleted;
    showImportance = widget.showImportance;
    uwuifier = widget.uwuifier;
    themeMode = widget.themeMode;
    themeModeCallback = widget.themeModeCallback;
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
                child: Icon(Icons.arrow_back),
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
                      title: Text('uwuifier mode'),
                      value: uwuifier,
                      onChanged: (value) {
                        setState(() {
                          uwuifier = value;
                        });
                        saveSettings();
                      },
                    ),
                    DropdownButtonFormField<ThemeMode>(
                      initialValue: themeMode,
                      decoration: InputDecoration(
                        labelText: 'Theme',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: const Row(
                            children: [
                              Icon(Icons.light_mode),
                              SizedBox(width: 8),
                              Text('Light'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: const Row(
                            children: [
                              Icon(Icons.dark_mode),
                              SizedBox(width: 8),
                              Text('Dark'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: const Row(
                            children: [
                              Icon(Icons.computer),
                              SizedBox(width: 8),
                              Text('System setting'),
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
          ],
        ),
      ),
    );
  }
}
