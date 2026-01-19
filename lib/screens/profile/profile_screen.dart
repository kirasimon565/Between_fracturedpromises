import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../app/constants.dart';
import '../../theme/colors.dart';
import 'profile_controller.dart';
import 'verification_badge.dart';
import 'profile_info_card.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  
  // Logic to determine if this is the "User" (Nadia) or a "Character"
  final bool isNadia; 
  final String characterId;

  ProfileScreen({Key? key, this.isNadia = true, this.characterId = 'nadia'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          isNadia ? "MY PROFILE" : "CHARACTER PROFILE", 
          style: const TextStyle(letterSpacing: 4, fontSize: 12, fontWeight: FontWeight.w300)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 40),
            
            // 1. The Paradox Slider & Rounded Profile Picture
            Center(
              child: _ParadoxAvatarSlider(isNadia: isNadia),
            ),

            const SizedBox(height: 30),

            // 2. Name and Age
            Obx(() => Text(
              "${controller.name.value.toUpperCase()}, ${controller.age.value}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w200,
                letterSpacing: 3,
                fontFamily: 'Didot'
              ),
            )),

            const SizedBox(height: 40),

            // 3. Professional Information Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: _buildProfessionalCard(),
            ),

            const SizedBox(height: 30),

            // 4. Social Stats
            _buildStatRow(),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.notes_rounded, "BIO", controller.bio.value),
          const Divider(color: Colors.white10, height: 30),
          _infoRow(Icons.location_on_outlined, "LOCATION", "NEW YORK, NY"),
          const Divider(color: Colors.white10, height: 30),
          _infoRow(Icons.work_outline_rounded, "OCCUPATION", "SENIOR GRAPHIC DESIGNER"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStat("CONNECTIONS", "1.2K"),
        _buildStat("MEDIA", "402"),
        _buildStat("LIKES", "8.2K"),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w200)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 1)),
      ],
    );
  }
}

class _ParadoxAvatarSlider extends StatefulWidget {
  final bool isNadia;
  const _ParadoxAvatarSlider({required this.isNadia});

  @override
  __ParadoxAvatarSliderState createState() => __ParadoxAvatarSliderState();
}

class __ParadoxAvatarSliderState extends State<_ParadoxAvatarSlider> {
  double _sliderValue = 0.0; // 0.0 = Profile, 1.0 = Gallery

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 🛠️ Outer Ring for Professional Look
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              ),
            ),

            // 📸 The Gallery Image (Hidden behind/revealed by slider)
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('assets/gallery/photo_1.jpg'), // Placeholder
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 👤 The Profile Avatar (Rounded and masked)
            Opacity(
              opacity: (1.0 - _sliderValue).clamp(0.0, 1.0),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(AppConstants.avatarNadia),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)
                  ],
                ),
              ),
            ),

            // 🛠️ The Pen Icon (ONLY for Nadia)
            if (widget.isNadia)
              Positioned(
                child: GestureDetector(
                  onTap: () => Get.toNamed('/profile/edit'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
            
            Positioned(bottom: 10, right: 10, child: VerificationBadge()),
          ],
        ),

        const SizedBox(height: 25),

        // 🛠️ Paradox Slider Control
        SizedBox(
          width: 200,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 1,
              activeTrackColor: Colors.white30,
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: (v) => setState(() => _sliderValue = v),
            ),
          ),
        ),
        Text(
          _sliderValue > 0.5 ? "GALLERY MODE" : "PROFILE MODE",
          style: const TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2),
        ),
      ],
    );
  }
}
