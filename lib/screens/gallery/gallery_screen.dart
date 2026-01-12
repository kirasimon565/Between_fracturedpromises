import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gallery_controller.dart';
import 'gallery_viewer.dart';
import '../../theme/colors.dart';

class GalleryScreen extends StatelessWidget {
  final GalleryController controller = Get.put(GalleryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark vault theme
      appBar: AppBar(
        title: const Text("GALLERY", style: TextStyle(letterSpacing: 4, fontSize: 13)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.unlockedImages.isEmpty) {
          return Center(
            child: Text(
              "NO EVIDENCE FOUND",
              style: TextStyle(color: Colors.white24, letterSpacing: 2, fontSize: 12),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4, // Tight spacing for a "fragmented" look
            mainAxisSpacing: 4,
          ),
          itemCount: controller.unlockedImages.length,
          itemBuilder: (context, index) {
            final path = controller.unlockedImages[index];
            return GestureDetector(
              onTap: () => Get.to(() => GalleryViewer(imagePath: path), transition: Transition.fade),
              child: Hero(
                tag: path,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(2), // Sharp edges to match splash
                    image: DecorationImage(
                      image: AssetImage(path), 
                      fit: BoxFit.cover,
                      // Desaturate thumbnails slightly for a noir feel
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
