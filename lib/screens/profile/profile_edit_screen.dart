import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/colors.dart';
import '../../services/audio_service.dart';
import 'profile_controller.dart';

class ProfileEditScreen extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();
  final AudioService _audioService = Get.find<AudioService>(); // 🔊 For haptic feedback
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  ProfileEditScreen({Key? key}) : super(key: key) {
    nameController.text = controller.name.value;
    bioController.text = controller.bio.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Consistent Noir base
      appBar: AppBar(
        title: const Text(
          "EDIT IDENTITY", 
          style: TextStyle(fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.w300)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22, color: Colors.white70), 
          onPressed: () => Get.back()
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 🔊 Audio Feedback: Confirm save
              _audioService.playPing(); 
              controller.saveProfile(nameController.text, bioController.text);
              Get.back();
            },
            child: const Text(
              "DONE", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, letterSpacing: 1)
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("NAME IDENTIFIER"),
            _buildTextField(nameController, false),
            
            const SizedBox(height: 40),
            
            _buildLabel("PERSONAL BIOGRAPHY"),
            _buildTextField(bioController, true),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                "These details will update across all secure networks.",
                style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.3), 
          fontSize: 9, 
          letterSpacing: 2, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, bool isMultiline) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextField(
        controller: controller,
        maxLines: isMultiline ? 5 : 1,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 15),
        cursorColor: Colors.white30,
        decoration: const InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
