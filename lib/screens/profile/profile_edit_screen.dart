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
        title: Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: AppColors.makelovePrimary),
            onPressed: () {
              controller.saveProfile(nameController.text, bioController.text);
              Get.back();
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: bioController,
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Bio",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
