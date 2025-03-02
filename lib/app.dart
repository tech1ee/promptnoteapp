import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_note_app/features/auth/screens/login_screen.dart';
import 'package:prompt_note_app/features/datasets/screens/home_screen.dart';
import 'package:prompt_note_app/services/mock_auth_service.dart';
import 'package:prompt_note_app/features/prompts/screens/prompt_generator_screen.dart';
import 'package:prompt_note_app/features/settings/screens/settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptNoteApp extends StatelessWidget {
  const PromptNoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompt Note',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
          primary: const Color(0xFF6750A4),
          secondary: const Color(0xFF625B71),
          tertiary: const Color(0xFF7D5260),
          background: const Color(0xFFF8F8FC),
          surface: const Color(0xFFFFFFFF),
        ),
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(
          Theme.of(context).textTheme.copyWith(
            titleLarge: GoogleFonts.jetBrainsMono(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
            titleMedium: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
            bodyLarge: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.3,
            ),
            bodyMedium: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.3,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF8F8FC),
          foregroundColor: const Color(0xFF1C1B1F),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.jetBrainsMono(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C1B1F),
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: const Color(0xFFE0E0E0), width: 1),
          ),
          color: Colors.white,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE0E0E0),
          thickness: 1,
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6750A4), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6750A4),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF6750A4),
          size: 24,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF6750A4);
            }
            return const Color(0xFFE0E0E0);
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF6750A4).withOpacity(0.5);
            }
            return const Color(0xFFE0E0E0);
          }),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
          primary: const Color(0xFFD0BCFF),
          secondary: const Color(0xFFCCC2DC),
          tertiary: const Color(0xFFEFB8C8),
          background: const Color(0xFF1C1B1F),
          surface: const Color(0xFF2D2C31),
        ),
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(
          ThemeData.dark().textTheme.copyWith(
            titleLarge: GoogleFonts.jetBrainsMono(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
            titleMedium: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
            bodyLarge: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.3,
              color: Colors.white,
            ),
            bodyMedium: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.3,
              color: Colors.white,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1C1B1F),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.jetBrainsMono(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: const Color(0xFF3E3D42), width: 1),
          ),
          color: const Color(0xFF2D2C31),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF3E3D42),
          thickness: 1,
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2D2C31),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0BCFF), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD0BCFF),
            foregroundColor: const Color(0xFF1C1B1F),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFD0BCFF),
          size: 24,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFFD0BCFF);
            }
            return const Color(0xFF3E3D42);
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFFD0BCFF).withOpacity(0.5);
            }
            return const Color(0xFF3E3D42);
          }),
        ),
      ),
      themeMode: ThemeMode.system,
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Datasets',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Prompts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
} 