import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/colors.dart';
import 'profile_controller.dart';

class ProfileEditScreen extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  ProfileEditScreen() {
    nameController.text = controller.name.value;
    bioController.text = controller.bio.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.makeloveBackground,
      appBar: AppBar(
        title: const Text("MODIFIKASI", style: TextStyle(fontSize: 13, letterSpacing: 2)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
        actions: [
          TextButton(
            onPressed: () {
              controller.saveProfile(nameController.text, bioController.text);
              Get.back();
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              decoration: const InputDecoration(
                labelText: "NAME IDENTIFIER",
                labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300, height: 1.5),
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "PERSONAL BIOGRAPHY",
                labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
