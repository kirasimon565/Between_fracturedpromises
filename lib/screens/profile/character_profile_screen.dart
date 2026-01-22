import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/professional_info_card.dart';
import '../../../app/constants.dart';
import '../../../theme/colors.dart';

class CharacterProfileScreen extends StatelessWidget {
  final String characterId;
  final String name;
  final String bio;
  final String avatarPath;
  final Color themeColor;

  const CharacterProfileScreen({
    Key? key,
    required this.characterId,
    this.name = "Unknown",
    this.bio = "No data available.",
    this.avatarPath = AppConstants.avatarEthan, // Default fallback
    this.themeColor = AppColors.messengerPrimary,
  }) : super(key: key);

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
            const SizedBox(height: 40),

            // 1. Static Avatar (No Slider for NPCs yet)
            Hero(
              tag: 'avatar_$characterId',
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(avatarPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 2. Identity (Read Only)
            Text(
              name.toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "CONTACT",
              style: const TextStyle(
                color: Colors.white24,
                fontSize: 10,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 30),

            // 3. Bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProfessionalInfoCard(
                bio: bio,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
