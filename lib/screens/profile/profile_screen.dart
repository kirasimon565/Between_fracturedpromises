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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("PROFIL", style: TextStyle(letterSpacing: 4, fontSize: 14, fontFamily: 'Inter')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
            onPressed: () => Get.toNamed('/profile/edit'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: _AvatarSlider(),
            ),
            const SizedBox(height: 25),
            Obx(() => Text(
              "${controller.name.value.toUpperCase()}, ${controller.age.value}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                fontFamily: 'Didot'
              ),
            )),
            const SizedBox(height: 40),
            // "Resume of a Lie" Info Cards
            Obx(() => ProfileInfoCard(
              title: "STATUS / BIO",
              content: controller.bio.value,
              icon: Icons.notes,
            )),
            const ProfileInfoCard(title: "CURRENT LOCATION", content: "NEW YORK, NY", icon: Icons.location_on_outlined),
            const ProfileInfoCard(title: "DESIGNATED ROLE", content: "GRAPHIC DESIGNER", icon: Icons.work_outline),
            const SizedBox(height: 20),
            // Fake Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat("CONNECTIONS", "128"),
                _buildStat("MEDIA", "1,402"),
                _buildStat("LIKES", "8.2K"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }
}

class _AvatarSlider extends StatefulWidget {
  @override
  __AvatarSliderState createState() => __AvatarSliderState();
}

class __AvatarSliderState extends State<_AvatarSlider> {
  double _sliderValue = 0.0; // 0 = Revealed, 1 = Hidden (or vice versa paradox effect)

  // "Slider reveals / hides" - Gallery paradox effect.
  // Implementation: Use a ShaderMask or ClipPath driven by the slider.
  // Or simple Opacity/Blur transition.
  // Let's do a "Pixelate" or "Blur" effect that increases with slider.
  // Since we don't have pixelate shader ready, let's do Opacity + Overlay.

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1),
              ),
            ),
            // The Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(AppConstants.avatarNadia),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // The Hider Overlay
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(_sliderValue), // Hides the face
              ),
            ),
            Positioned(bottom: 5, right: 5, child: VerificationBadge()),
          ],
        ),
        const SizedBox(height: 15),
        // The Slider Control
        SizedBox(
          width: 150,
          height: 30,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayColor: Colors.white.withOpacity(0.1),
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: (v) => setState(() => _sliderValue = v),
              min: 0.0,
              max: 1.0,
            ),
          ),
        ),
        Text(
          "VISIBILITY: ${((1.0 - _sliderValue) * 100).toInt()}%",
          style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
        ),
      ],
    );
  }
}
