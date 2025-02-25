// import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_note_app/services/mock_auth_service.dart';
import 'package:prompt_note_app/services/mock_database_service.dart';
import 'package:prompt_note_app/services/mock_storage_service.dart';
import 'package:prompt_note_app/services/prompt_service.dart';
import 'package:prompt_note_app/services/mock_purchase_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable provider debug checks - optional if you want to remove the red screen
  Provider.debugCheckInvalidValueType = null;
  
  runApp(
    MultiProvider(
      providers: [
        Provider<MockAuthService>(
          create: (_) => MockAuthService(),
        ),
        Provider<MockDatabaseService>(
          create: (_) => MockDatabaseService(),
        ),
        Provider<MockStorageService>(
          create: (_) => MockStorageService(),
        ),
        ChangeNotifierProvider<PromptService>(
          create: (_) => PromptService(),
        ),
      ],
      child: const PromptNoteApp(),
    ),
  );
} 