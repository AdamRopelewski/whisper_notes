import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisper_notes/models/prompt_style.dart';
import 'package:whisper_notes/config/routes.dart';
import 'package:whisper_notes/services/whisper_service.dart';
import 'package:whisper_notes/services/llm_service.dart';

void main() {
  runApp(const WhisperNotesApp());
}

class WhisperNotesApp extends StatelessWidget {
  const WhisperNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PromptStyleProvider()),
        Provider(create: (_) => WhisperService()),
        Provider(create: (_) => LlmService()),
      ],
      child: MaterialApp.router(
        title: 'Whisper Notes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}