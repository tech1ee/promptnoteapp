import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_note_app/features/auth/screens/login_screen.dart';
import 'package:prompt_note_app/features/datasets/screens/home_screen.dart';
import 'package:prompt_note_app/services/mock_auth_service.dart';
import 'package:prompt_note_app/features/prompts/screens/prompt_generator_screen.dart';
import 'package:prompt_note_app/features/settings/screens/settings_screen.dart';

class PromptNoteApp extends StatelessWidget {
  const PromptNoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompt Note',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AppHome(),
    );
  }
}

class AppHome extends StatefulWidget {
  const AppHome({Key? key}) : super(key: key);

  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  int _selectedIndex = 1; // Start on Prompts tab
  
  static final List<Widget> _screens = [
    const HomeScreen(), // Use existing HomeScreen instead of NotesListScreen
    const PromptGeneratorScreen(),
    const SettingsScreen(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Datasets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Prompts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
} 