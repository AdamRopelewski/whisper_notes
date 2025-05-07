import 'package:flutter/material.dart';
import 'package:whisper_notes/services/audio_service.dart';

class RecordingButton extends StatefulWidget {
  final AudioService audioService;
  final Function(String? path) onRecordingComplete;

  const RecordingButton({
    Key? key,
    required this.audioService,
    required this.onRecordingComplete,
  }) : super(key: key);

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      final audioPath = await widget.audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _animationController.stop();
      });
      widget.onRecordingComplete(audioPath);
    } else {
      // Check permission and start recording
      bool hasPermission = await widget.audioService.checkPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mikrofonem jest wymagany do nagrywania'),
            ),
          );
        }
        return;
      }
      
      bool started = await widget.audioService.startRecording();
      if (started) {
        setState(() {
          _isRecording = true;
          _animationController.repeat(reverse: true);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nie udało się rozpocząć nagrywania'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleRecording,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _animation.value : 1.0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red : Colors.teal,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51), 
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }
}