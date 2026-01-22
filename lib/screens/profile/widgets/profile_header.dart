import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/constants.dart';
import '../../../../theme/colors.dart';
import '../../gallery/gallery_controller.dart'; // Correct relative path from widgets/profile_header.dart

class ProfileHeaderWidget extends StatelessWidget {
  final bool isParadoxMode;
  final VoidCallback onToggle;

  const ProfileHeaderWidget({
    Key? key,
    required this.isParadoxMode,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GalleryController galleryController = Get.find<GalleryController>();

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // 1. The "Paradox" Gallery Layer (Hidden or Revealed)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            left: isParadoxMode ? 0 : MediaQuery.of(context).size.width,
            right: isParadoxMode ? 0 : -MediaQuery.of(context).size.width,
            top: 0,
            bottom: 0,
            child: Obx(() {
              final images = galleryController.unlockedImages;
              if (images.isEmpty) {
                return _buildEmptyState();
              }
              return PageView.builder(
                itemCount: images.length,
                controller: PageController(viewportFraction: 0.85),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(images[index]), // Or Network/File if needed
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.makelovePrimary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // 2. The "Professional" Avatar Layer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            left: isParadoxMode ? -200 : 0, // Slide off screen
            right: isParadoxMode ? 200 : 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  onToggle(); // Swipe Left to reveal paradox
                }
              },
              child: Center(
                child: Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.messengerPrimary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(AppConstants.avatarNadia), // Professional Avatar
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Visual Hint
          if (!isParadoxMode)
            Positioned(
              right: 20,
              top: 100,
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.1),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "NO DATA FRAGMENTS RECOVERED",
        style: TextStyle(
          color: Colors.white24,
          letterSpacing: 2,
          fontSize: 12,
          fontFamily: 'Courier',
        ),
      ),
    );
  }
}
