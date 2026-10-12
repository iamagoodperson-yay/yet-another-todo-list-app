import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  final bool autoDeleteCompleted;
  final bool showImportance;

  const SettingsView({super.key, required this.autoDeleteCompleted, required this.showImportance});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {  
  late bool autoDeleteCompleted;
  late bool showImportance;

  late final double _width = MediaQuery.of(context).size.width;

  void closeSettings() {
    Navigator.pop(
      context,
      {
        'autoDeleteCompleted': autoDeleteCompleted,
        'showImportance': showImportance
      }
    );
  }

  @override
  void initState() {
    super.initState();

    autoDeleteCompleted = widget.autoDeleteCompleted;
    showImportance = widget.showImportance;
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
                  children: [
                    SwitchListTile(
                      title: Text('Auto-delete completed todos'),
                      value: autoDeleteCompleted,
                      onChanged: (value) {
                        setState(() {
                          autoDeleteCompleted = value;
                        });
                      },
                    ),
                    // SwitchListTile(
                    //   title: Text('Show importance'),
                    //   value: showImportance,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       showImportance = value;
                    //     });
                    //   },
                    // ),
                  ]
                )
              ),
            ),
          ]
        ),
      )
    );
  }
}