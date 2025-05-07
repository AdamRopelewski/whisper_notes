import 'package:flutter/material.dart';
import 'package:whisper_notes/config/routes.dart' show appRouter;
import 'package:whisper_notes/config/theme.dart';

class WhisperNotesApp extends StatelessWidget {
  const WhisperNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Whisper Notes',
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}