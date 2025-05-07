import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whisper Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.record_voice_over,
              size: 100,
              color: Colors.teal,
            ),
            const SizedBox(height: 32),
            const Text(
              'Witaj w Whisper Notes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Zamień swoje nagrania audio na tekst, a następnie twórz podsumowania za pomocą AI',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.go('/transcribe'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Rozpocznij transkrypcję'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go('/summarize', extra: {'transcription': ''}),
              child: const Text('Przejdź do podsumowania'),
            ),
          ],
        ),
      ),
    );
  }
}