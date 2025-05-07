import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioService {
  final _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;

  Future<bool> checkPermission() async {
    if (await Permission.microphone.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  Future<bool> startRecording() async {
    try {
      // Check if already recording
      if (await _audioRecorder.isRecording()) {
        return false;
      }
      
      if (await checkPermission()) {
        final directory = await getTemporaryDirectory();
        _currentRecordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ), path: _currentRecordingPath!);
        return true;
      }
      return false;
    } catch (e) {
      _currentRecordingPath = null;
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
        final path = _currentRecordingPath;
        _currentRecordingPath = null;
        return path;
      }
      return null;
    } catch (e) {
      _currentRecordingPath = null;
      return null;
    }
  }

  Future<String?> pickAudioFile() async {
    try {
      final XTypeGroup audioGroup = XTypeGroup(
        label: 'Audio',
        extensions: ['m4a', 'mp3', 'wav'],
      );
      final XFile? file = await openFile(acceptedTypeGroups: [audioGroup]);

      if (file != null) {
        return file.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> dispose() async {
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }
    await _audioRecorder.dispose();
  }
}