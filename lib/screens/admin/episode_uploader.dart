import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../services/firestore_service.dart';
import '../../services/audio_service.dart';
import '../../theme/colors.dart';

class EpisodeUploader extends StatefulWidget {
  @override
  _EpisodeUploaderState createState() => _EpisodeUploaderState();
}

class _EpisodeUploaderState extends State<EpisodeUploader> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AudioService _audio = Get.find<AudioService>();
  bool _isLoading = false;

  void _upload() async {
    // 🔊 Play mechanical sound on press
    _audio.playVibrate();

    if (_idController.text.isEmpty || _jsonController.text.isEmpty) {
      Get.snackbar("ACCESS DENIED", "Data fields must not be null.", 
        backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    // Basic JSON Validation before sending to Cloud
    try {
      json.decode(_jsonController.text);
    } catch (e) {
      Get.snackbar("SYNTAX ERROR", "Invalid JSON structure detected.", 
        backgroundColor: Colors.orange.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _firestore.uploadEpisodeScript(_idController.text.trim(), _jsonController.text);
      
      _audio.playPing(); // Success sound
      Get.snackbar("UPLOAD COMPLETE", "Episode ${_idController.text} integrated into cloud nodes.", 
        backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
      
      _jsonController.clear();
      _idController.clear();
    } catch (e) {
      Get.snackbar("TRANSMISSION FAILED", e.toString(), 
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CORE // EPISODE_UPLOADER", 
          style: TextStyle(fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("EPISODE IDENTIFIER"),
            _buildIdField(),
            const SizedBox(height: 30),
            _buildLabel("SCRIPT DATA (JSON)"),
            _buildCodeEditor(),
            const SizedBox(height: 25),
            _buildExecuteButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(text, style: const TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2)),
    );
  }

  Widget _buildIdField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: _idController,
        style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontFamily: 'monospace'),
        decoration: const InputDecoration(
          hintText: "e.g. episode_01_final",
          hintStyle: TextStyle(color: Colors.white12, fontSize: 12),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCodeEditor() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: TextField(
          controller: _jsonController,
          maxLines: null,
          expands: true,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace', height: 1.5),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(20),
            border: InputBorder.none,
            hintText: "{\n  \"messages\": [...]\n}",
            hintStyle: TextStyle(color: Colors.white10),
          ),
        ),
      ),
    );
  }

  Widget _buildExecuteButton() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
        : SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.withOpacity(0.05),
                side: const BorderSide(color: Colors.greenAccent, width: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _upload, 
              child: const Text("EXECUTE TRANSMISSION", 
                style: TextStyle(color: Colors.greenAccent, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          );
  }
}
