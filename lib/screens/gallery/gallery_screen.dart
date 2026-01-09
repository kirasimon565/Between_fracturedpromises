import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gallery_controller.dart';
import 'gallery_viewer.dart';

class GalleryScreen extends StatelessWidget {
  final GalleryController controller = Get.put(GalleryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gallery")),
      body: Obx(() => GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: controller.unlockedImages.length,
        itemBuilder: (context, index) {
          final path = controller.unlockedImages[index];
          return GestureDetector(
            onTap: () => Get.to(() => GalleryViewer(imagePath: path)),
            child: Hero(
              tag: path,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
                ),
              ),
            ),
          );
        },
      )),
    );
  }
}
