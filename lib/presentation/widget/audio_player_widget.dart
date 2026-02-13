import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String filePath;
  final int index;
  final VoidCallback onRemove;

  const AudioPlayerWidget({
    super.key,
    required this.filePath,
    required this.index,
    required this.onRemove,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late PlayerController _playerController;
  bool isPlaying = false;
  int? maxDurationMs;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    _load();
  }

  Future<void> _load() async {
    await _playerController.preparePlayer(path: widget.filePath);
    maxDurationMs = _playerController.maxDuration;
    _playerController.onCompletion.listen((_) {
      setState(() => isPlaying = false);
    });
    setState(() {});
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  String formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final durationText = maxDurationMs != null
        ? formatMs(maxDurationMs!)
        : '--:--';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 30,
                  ),
                  onPressed: () async {
                    if (isPlaying) {
                      await _playerController.pausePlayer();
                    } else {
                      await _playerController.startPlayer();
                    }
                    setState(() => isPlaying = !isPlaying);
                  },
                ),
                Expanded(
                  child: Text(
                    "Voice Note ${widget.index + 1}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(durationText, style: const TextStyle(color: Colors.grey)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),

            const SizedBox(height: 8),
            AudioFileWaveforms(
              size: const Size(double.infinity, 70),
              playerController: _playerController,
              enableSeekGesture: true,
              waveformType: WaveformType.long,
              playerWaveStyle: const PlayerWaveStyle(
                fixedWaveColor: Colors.grey,
                liveWaveColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
