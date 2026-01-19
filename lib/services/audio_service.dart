import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart'; // Add this package
import '../app/constants.dart';

class AudioService extends GetxService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  void playMusic(String trackName) async {
    // 🛠️ Path Fix: Use your assets/music/ directory
    await _musicPlayer.play(AssetSource('music/$trackName')); 
  }

  void playSfx(String sfxName) async {
    // 🛠️ Path Fix: Use your assets/fx/ directory
    await _sfxPlayer.play(AssetSource('fx/$sfxName'));
  }

  void stopMusic() {
    _musicPlayer.stop();
  }
}
