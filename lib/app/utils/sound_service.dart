import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Plays a sound in a loop
  static Future<void> playLoop(String assetPath) async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // ignore
    }
  }

  /// Plays a sound once
  static Future<void> playOnce(String assetPath) async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // ignore
    }
  }

  /// Stops any currently playing sound
  static Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      // ignore
    }
  }

  /// Dispose the player when app closes (optional but good practice)
  static void dispose() {
    _audioPlayer.dispose();
  }
}
