import 'package:audioplayers/audioplayers.dart';

class TransitionTonePreviewService {
  final AudioPlayer _player = AudioPlayer();

  static String assetForPreference(String value) {
    return switch (value) {
      'femenina' => 'sounds/burbuja.wav',
      'masculina' => 'sounds/platillo.wav',
      'ambient' => 'sounds/bell.wav',
      _ => 'sounds/bell.wav',
    };
  }

  Future<void> playTone(String value) async {
    await _player.stop();
    await _player.play(AssetSource(assetForPreference(value)), volume: 0.7);
  }

  Future<void> stop() => _player.stop();

  Future<void> dispose() async {
    await _player.dispose();
  }
}
