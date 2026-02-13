import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';

import 'package:path_provider/path_provider.dart';

import 'package:record/record.dart';

import 'package:uuid/uuid.dart';

class VoiceManager {
  final RecorderController recorderController = RecorderController();

  final AudioRecorder _record = AudioRecorder();

  String? _currentPath;
  Future<String?> startRecording() async {
    final hasPermission = await _record.hasPermission();

    if (!hasPermission) return null;
    final dir = await getApplicationDocumentsDirectory();

    final filePath = "${dir.path}/${const Uuid().v4()}.m4a";

    _currentPath = filePath;

    await _record.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc, // High-quality AAC format
        bitRate: 128000, // Audio quality
        sampleRate: 44100, // CD-quality sampling rate
      ),
      path: filePath, // Where audio will be saved
    );

    recorderController.reset();

    await recorderController.record();

    return filePath;
  }

  Future<String?> stopRecording() async {
    await recorderController.stop();
    final saved = await _record.stop();
    return saved ?? _currentPath;
  }
}
