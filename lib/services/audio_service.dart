import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService extends GetxService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _fxPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    // Keep the noir themes looping for atmosphere
    _musicPlayer.setReleaseMode(ReleaseMode.loop); 
  }

  // --- NEW: GENERIC THEME METHOD ---
  // This fixes the 'playTheme' error in your WelcomeScreen
  void playTheme(String trackName) => _playMusic(trackName);

  // --- MUSIC METHODS ---
  void playIntroTheme() => _playMusic('theme_intro.mp3');
  void playChatTheme() => _playMusic('theme_chat.mp3');
  void playTragedyTheme() => _playMusic('theme_tragedy.mp3');

  // --- FX METHODS ---
  // Maps to assets/fx/ as defined in your pubspec
  void playShatter() => _playSfx('glass_shatter.mp3');
  void playPing() => _playSfx('msg_ping.mp3');
  void playSend() => _playSfx('msg_send.mp3');
  void playTyping() => _playSfx('typing.mp3');
  void playVibrate() => _playSfx('vibrate.mp3');

  // Internal Helpers
  Future<void> _playMusic(String track) async {
    try {
      await _musicPlayer.stop();
      // Plays from assets/music/
      await _musicPlayer.play(AssetSource('music/$track'));
    } catch (e) {
      print("Error playing music: $e");
    }
  }

  Future<void> _playSfx(String sfx) async {
    try {
      // Plays from assets/fx/
      await _fxPlayer.play(AssetSource('fx/$sfx'));
    } catch (e) {
      print("Error playing sfx: $e");
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
