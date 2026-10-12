import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {  
  void closeSettings() => {
    Navigator.pop(context)
  };

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
            Center(
              child: Text("Settings"),
            ),
          ]
        ),
      )
    );
  }
}