import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whisper_notes/screens/welcome_screen.dart';
import 'package:whisper_notes/screens/transcription_screen.dart';
import 'package:whisper_notes/screens/summarization_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/transcribe',
      builder: (context, state) => const TranscriptionScreen(),
    ),
    GoRoute(
      path: '/summarize',
      name: 'summarize',
      builder: (context, state) {
        final Map<String, dynamic> args = state.extra as Map<String, dynamic>? ?? {};
        final String transcription = args['transcription'] as String? ?? '';
        return SummarizationScreen(transcription: transcription);
      },
    ),
  ],
);