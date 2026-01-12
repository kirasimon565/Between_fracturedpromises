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
        title: const Text("PROFIL", style: TextStyle(letterSpacing: 4, fontSize: 14)), // International system feel
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white70, size: 20), // More "Settings" style icon
            onPressed: () => Get.toNamed('/profile/edit'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer decorative ring
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.makelovePrimary.withOpacity(0.3), width: 1),
                    ),
                  ),
                  CircleAvatar(
                    radius: 58,
                    backgroundImage: AssetImage(AppConstants.avatarNadia), // Your Nadia asset
                  ),
                  Positioned(bottom: 5, right: 5, child: VerificationBadge()),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Obx(() => Text(
              "${controller.name.value.toUpperCase()}, ${controller.age.value}",
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300, letterSpacing: 2),
            )),
            const SizedBox(height: 40),
            Obx(() => ProfileInfoCard(
              title: "STATUS / BIO",
              content: controller.bio.value,
              icon: Icons.notes,
            )),
            const ProfileInfoCard(title: "CURRENT LOCATION", content: "NEW YORK, NY", icon: Icons.map_outlined),
            const ProfileInfoCard(title: "DESIGNATED ROLE", content: "GRAPHIC DESIGNER", icon: Icons.terminal_outlined),
          ],
        ),
      ),
    );
  }
}
