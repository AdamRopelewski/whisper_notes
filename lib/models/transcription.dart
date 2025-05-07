class Transcription {
  final String text;
  final DateTime timestamp;
  final String audioPath;
  
  Transcription({
    required this.text,
    required this.timestamp,
    required this.audioPath,
  });
  
  // For use with the simplified string-based approach
  String get content => text;
  
  // Allow using the object as a string
  @override
  String toString() => text;
  
  // Check if empty
  bool get isEmpty => text.isEmpty;
  bool get isNotEmpty => text.isNotEmpty;
}