import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:phr/data/services/voice_manager.dart';

class AudioRecordSheet extends StatefulWidget {
  final VoiceManager voiceManager;
  final Function(String path) onSave;

  const AudioRecordSheet({
    super.key,
    required this.voiceManager,
    required this.onSave,
  });

  @override
  State<AudioRecordSheet> createState() => _AudioRecordSheetState();
}

class _AudioRecordSheetState extends State<AudioRecordSheet> {
  int seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => seconds++),
    );
  }

  String format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return "$m:$ss";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Recording…",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          AudioWaveforms(
            size: Size(MediaQuery.of(context).size.width, 80),

            recorderController: widget.voiceManager.recorderController,
            enableGesture: false,

            waveStyle: const WaveStyle(
              waveColor: Colors.blue,
              extendWaveform: true,
              showMiddleLine: false,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            format(seconds),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () async {
              final saved = await widget.voiceManager.stopRecording();

              if (saved != null) {
                widget.onSave(saved);
              }

              Navigator.pop(context);
            },

            icon: const Icon(Icons.stop),
            label: const Text("Stop Recording"),

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
            ),
          ),
        ],
      ),
    );
  }
}
