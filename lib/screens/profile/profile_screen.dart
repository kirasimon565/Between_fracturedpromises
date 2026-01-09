import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../theme/colors.dart';
import 'profile_controller.dart';
import 'verification_badge.dart';
import 'profile_info_card.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.makeloveBackground,
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.makelovePrimary),
            onPressed: () => Get.toNamed('/profile/edit'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(AppConstants.avatarNadia),
                  backgroundColor: Colors.grey,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: VerificationBadge(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Obx(() => Text(
                  "${controller.name.value}, ${controller.age.value}",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                )),
            SizedBox(height: 30),
            Obx(() => ProfileInfoCard(
              title: "Bio",
              content: controller.bio.value,
              icon: Icons.format_quote
            )),
            ProfileInfoCard(title: "Location", content: "New York, NY", icon: Icons.location_on),
            ProfileInfoCard(title: "Occupation", content: "Graphic Designer", icon: Icons.work),
          ],
        ),
      ),
    );
  }
}
