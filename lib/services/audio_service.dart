import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService extends GetxService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _fxPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    _musicPlayer.setReleaseMode(ReleaseMode.loop); // Keep the noir themes looping
  }

  // --- MUSIC METHODS ---
  void playIntroTheme() => _playMusic('theme_intro.mp3');
  void playChatTheme() => _playMusic('theme_chat.mp3');
  void playTragedyTheme() => _playMusic('theme_tragedy.mp3');

  // --- FX METHODS ---
  void playShatter() => _playSfx('glass_shatter.mp3');
  void playPing() => _playSfx('msg_ping.mp3');
  void playSend() => _playSfx('msg_send.mp3');
  void playTyping() => _playSfx('typing.mp3');
  void playVibrate() => _playSfx('vibrate.mp3');

  // Internal Helpers
  Future<void> _playMusic(String track) async {
    await _musicPlayer.stop();
    await _musicPlayer.play(AssetSource('music/$track'));
  }

  Future<void> _playSfx(String sfx) async {
    await _fxPlayer.play(AssetSource('fx/$sfx'));
  }

  void stopAll() {
    _musicPlayer.stop();
    _fxPlayer.stop();
  }
}
