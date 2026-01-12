import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GalleryViewer extends StatelessWidget {
  final String imagePath;

  const GalleryViewer({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Fully immersive: the image is the only focus
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (_) => Get.back(), // Swipe away to close
        child: Center(
          child: Hero(
            tag: imagePath,
            child: InteractiveViewer( // Allows zooming into "evidence"
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
