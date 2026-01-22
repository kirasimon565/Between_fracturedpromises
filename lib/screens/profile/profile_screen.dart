import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/identity_edit_sheet.dart';
import 'widgets/professional_info_card.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 1. Paradox Slider
            Obx(() => ProfileHeaderWidget(
              isParadoxMode: controller.isParadoxMode.value,
              onToggle: controller.toggleParadoxMode,
            )),

            const SizedBox(height: 40),

            // 2. Identity Section
            Obx(() => _buildIdentitySection(context)),

            const SizedBox(height: 30),

            // 3. Professional Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() => ProfessionalInfoCard(
                bio: controller.bio.value,
                onExpand: () {
                  // TODO: Show stats expansion
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentitySection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.isParadoxMode.value
                  ? controller.makeloveAlias.value
                  : controller.messengerName.value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white54),
              onPressed: () => _showEditSheet(context),
            ),
          ],
        ),
        Text(
          controller.isParadoxMode.value ? "THE SECRET" : "THE MASK",
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 10,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IdentityEditSheet(
        currentMessengerName: controller.messengerName.value,
        currentMakeloveAlias: controller.makeloveAlias.value,
        onSave: controller.saveIdentity,
      ),
    );
  }
}
