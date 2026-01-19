import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'gallery_controller.dart';
import 'gallery_viewer.dart';
import '../../services/audio_service.dart';
import '../../theme/colors.dart';

class GalleryScreen extends StatelessWidget {
  final GalleryController controller = Get.put(GalleryController());
  final AudioService _audio = Get.find<AudioService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "SECURE GALLERY", 
          style: TextStyle(letterSpacing: 6, fontSize: 12, fontWeight: FontWeight.w300)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.unlockedImages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library_outlined, color: Colors.white.withOpacity(0.05), size: 64),
                const SizedBox(height: 16),
                Text(
                  "NO EVIDENCE RECOVERED",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.2), 
                    letterSpacing: 3, 
                    fontSize: 10
                  ),
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          itemCount: controller.unlockedImages.length,
          itemBuilder: (context, index) {
            final path = controller.unlockedImages[index];
            return _buildGalleryTile(path, index);
          },
        );
      }),
    );
  }

  Widget _buildGalleryTile(String path, int index) {
    return GestureDetector(
      onTap: () {
        _audio.playPing();
        Get.to(() => GalleryViewer(imagePath: path), transition: Transition.fadeIn);
      },
      child: Hero(
        tag: path,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Image.asset(
                  path,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.1),
                  colorBlendMode: BlendMode.darken,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
