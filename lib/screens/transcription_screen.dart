import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:whisper_notes/services/whisper_service.dart';
import 'package:go_router/go_router.dart';

class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({Key? key}) : super(key: key);

  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  final _audioRecorder = AudioRecorder();
  String? _recordedFilePath;
  String? _selectedFilePath;
  String? _transcription;
  bool _isRecording = false;
  bool _isTranscribing = false;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/audio_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: filePath);
        
        setState(() {
          _isRecording = true;
          _recordedFilePath = filePath;
          _selectedFilePath = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting recording: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() => _isRecording = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      final XTypeGroup audioGroup = XTypeGroup(
        label: 'Audio',
        extensions: ['m4a', 'mp3', 'wav'],
      );
      final XFile? file = await openFile(acceptedTypeGroups: [audioGroup]);

      if (file != null) {
        setState(() {
          _selectedFilePath = file.path;
          _recordedFilePath = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Future<void> _transcribe() async {
    final filePath = _recordedFilePath ?? _selectedFilePath;
    if (filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record or select an audio file first')),
      );
      return;
    }

    setState(() => _isTranscribing = true);

    try {
      final whisperService = Provider.of<WhisperService>(context, listen: false);
      final result = await whisperService.transcribeAudio(filePath);
      
      setState(() {
        _transcription = result;
        _isTranscribing = false;
      });
      
      if (result.isNotEmpty) {
        // Navigate to summarization screen with transcription
        context.go('/summarize', extra: {'transcription': result});
      }
    } catch (e) {
      setState(() => _isTranscribing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transcription error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,  // Allow automatic popping, but we'll handle navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Should not happen with canPop: true
          context.go('/');
        } else {
          // Navigate to home screen
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transkrypcja Audio'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'), // Go to welcome screen
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Audio source selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Źródło audio',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Record button
                          ElevatedButton.icon(
                            onPressed: _isRecording ? _stopRecording : _startRecording,
                            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                            label: Text(_isRecording ? 'Zatrzymaj' : 'Nagrywaj'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRecording ? Colors.red : null,
                            ),
                          ),
                          // File picker button
                          ElevatedButton.icon(
                            onPressed: _isRecording ? null : _pickAudioFile,
                            icon: const Icon(Icons.file_upload),
                            label: const Text('Wybierz plik'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // File status
              if (_recordedFilePath != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nagrane audio:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          _recordedFilePath!.split('/').last,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_selectedFilePath != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Wybrany plik:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilePath!.split('/').last,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // Transcribe button
              ElevatedButton(
                onPressed: (_recordedFilePath != null || _selectedFilePath != null) && !_isRecording && !_isTranscribing
                    ? _transcribe
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isTranscribing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 16),
                          Text('Transkrybuję...'),
                        ],
                      )
                    : const Text('Transkrybuj'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}