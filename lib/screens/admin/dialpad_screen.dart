import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../theme/colors.dart';
import '../../services/state_service.dart';
import '../../services/audio_service.dart'; // 🔊 Added for tactile feedback

class DialpadScreen extends StatefulWidget {
  @override
  _DialpadScreenState createState() => _DialpadScreenState();
}

class _DialpadScreenState extends State<DialpadScreen> {
  String _input = "";
  final StateService _stateService = Get.find<StateService>();
  final AudioService _audio = Get.find<AudioService>(); // 🔊 Found service

  void _onKeyPress(String key) {
    if (_input.length < 10) {
      _audio.playPing(); // 🔊 Every keypress provides a high-end "click"
      setState(() => _input += key);
      _checkCode();
    }
  }

  void _onDelete() {
    if (_input.isNotEmpty) {
      _audio.playVibrate(); // 🔊 Delete provides a heavier feedback
      setState(() => _input = _input.substring(0, _input.length - 1));
    }
  }

  void _checkCode() {
    // Secret access code: *#77*#
    if (_input == "*#77*#") {
      _audio.playVibrate(); // 🔊 Success haptic
      _stateService.unlockAdmin();
      
      // Navigate with a fade to feel like a system breach
      Get.offNamed(AppRoutes.adminDashboard);
    } else if (_input.length >= 8) {
      // Wrong code: Heavy feedback and auto-reset
      _audio.playVibrate(); 
      setState(() => _input = ""); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              "SYSTEM AUTHENTICATION", 
              style: TextStyle(
                color: Colors.white24, 
                letterSpacing: 6, 
                fontSize: 10,
                fontWeight: FontWeight.bold
              )
            ),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _input,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 42, 
                        letterSpacing: 10, 
                        fontWeight: FontWeight.w100
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_input.isNotEmpty)
                      Container(width: 40, height: 1, color: Colors.white10),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 30,
                  crossAxisSpacing: 30,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return _buildDialButton(_getKey(index));
                },
              ),
            ),

            // Back/Delete Control
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("CANCEL", 
                      style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2)),
                  ),
                  if (_input.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.backspace_outlined, color: Colors.white24, size: 20),
                      onPressed: _onDelete,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialButton(String key) {
    return GestureDetector(
      onTap: () => _onKeyPress(key),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.02),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Center(
          child: Text(
            key, 
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 28, 
              fontWeight: FontWeight.w100
            )
          ),
        ),
      ),
    );
  }

  String _getKey(int index) {
    if (index < 9) return "${index + 1}";
    if (index == 9) return "*";
    if (index == 10) return "0";
    return "#";
  }
}
