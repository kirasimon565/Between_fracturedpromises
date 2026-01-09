import 'package:get/get.dart';

class AudioService extends GetxService {
  // Placeholder for audio logic (music, sfx)
  // In a real app, use `audioplayers` or `just_audio` package

  void playMusic(String trackName) {
    print("Playing music: $trackName");
  }

  void playSfx(String sfxName) {
    print("Playing SFX: $sfxName");
  }

  void stopMusic() {
    print("Stopping music");
  }
}
