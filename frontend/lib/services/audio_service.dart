import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioRecorder _recorder = AudioRecorder();

  static Future<void> playUrl(String url) async {
    await _player.play(UrlSource(url));
  }

  static Future<void> stop() async {
    await _player.stop();
  }

  static Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  static Future<String?> startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
        ),
        path: path,
      );
      return path;
    }
    return null;
  }

  static Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  static Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  static void dispose() {
    _player.dispose();
    _recorder.dispose();
  }
}
