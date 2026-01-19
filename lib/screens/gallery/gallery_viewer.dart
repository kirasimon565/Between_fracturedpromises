import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/audio_service.dart';
import 'dart:ui';

class GalleryViewer extends StatefulWidget {
  final String imagePath;

  const GalleryViewer({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  final TransformationController _transformationController = TransformationController();
  final AudioService _audio = Get.find<AudioService>(); // 🔊 Found service
  bool _showUI = true;

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      // Zoom into the "Fractured" details
      _transformationController.value = Matrix4.identity()..scale(2.5);
      _audio.playPing(); //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true, 
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showUI ? 1.0 : 0.0,
          child: AppBar(
            backgroundColor: Colors.black.withOpacity(0.4),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share, color: Colors.white70, size: 20),
                onPressed: () {
                  _audio.playVibrate(); // 🔊
                  Get.snackbar(
                    "SYSTEM", "ENCRYPTED FILE SHARED TO MESSENGER",
                    colorText: Colors.white, backgroundColor: Colors.black87,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => setState(() => _showUI = !_showUI),
        onDoubleTap: _handleDoubleTap,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 500) Get.back(); // Drag down to exit
        },
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: widget.imagePath,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  panEnabled: true,
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Image.asset(widget.imagePath, fit: BoxFit.contain),
                ),
              ),
            ),
            
            // 🛠️ Metadata Glass Overlay
            if (_showUI)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.white.withOpacity(0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "RECOVERED DATA",
                            style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 2),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.imagePath.split('/').last.toUpperCase(),
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
