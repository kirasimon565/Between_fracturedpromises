import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../app/constants.dart';

class AudioService extends GetxService {
  // Separate players for music (looping) and FX (one-shot)
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _fxPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    // Pre-configure the music player to loop for ambient themes
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Plays background themes from the 'assets/music/' directory
  void playTheme(String trackName) async {
    try {
      await _musicPlayer.stop(); // Stop previous theme before starting new one
      // Flutter automatically looks in 'assets/' if registered in pubspec
      await _musicPlayer.play(AssetSource('music/$trackName')); 
    } catch (e) {
      print("Audio Error (Music): $e");
    }
  }

  /// Plays notifications or shatter sounds from the 'assets/fx/' directory
  void playNotification(String sfxName) async {
    try {
      // One-shot player for sharp sounds (shatter, clicks, notifications)
      await _fxPlayer.play(AssetSource('fx/$sfxName'));
    } catch (e) {
      print("Audio Error (FX): $e");
    }
  }

  void stopAll() {
    _musicPlayer.stop();
    _fxPlayer.stop();
  }

  @override
  void onClose() {
    _musicPlayer.dispose();
    _fxPlayer.dispose();
    super.onClose();
  }
}
