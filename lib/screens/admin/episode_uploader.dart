import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/firestore_service.dart';
import '../../theme/colors.dart';

class EpisodeUploader extends StatefulWidget {
  @override
  _EpisodeUploaderState createState() => _EpisodeUploaderState();
}

class _EpisodeUploaderState extends State<EpisodeUploader> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final FirestoreService _firestore = Get.find<FirestoreService>();
  bool _isLoading = false;

  void _upload() async {
    if (_idController.text.isEmpty || _jsonController.text.isEmpty) {
      Get.snackbar("Error", "Required fields empty", colorText: Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Logic for Firebase upload
      await _firestore.uploadEpisode(_idController.text.trim(), {
        'episode_id': _idController.text,
        'content': _jsonController.text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      Get.snackbar("Success", "Episode ${_idController.text} is now live!", 
        backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Upload Failed", e.toString(), backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("EPISODE UPLOADER", style: TextStyle(fontSize: 13)),
        backgroundColor: Colors.black,
        foregroundColor: AppColors.adminText,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              style: TextStyle(color: AppColors.adminText),
              decoration: InputDecoration(
                labelText: "EPISODE_ID",
                labelStyle: TextStyle(color: AppColors.adminText.withOpacity(0.5)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.adminText.withOpacity(0.2))),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _jsonController,
                maxLines: null,
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: "PASTE SCRIPT JSON",
                  labelStyle: TextStyle(color: AppColors.adminText.withOpacity(0.5)),
                  alignLabelWithHint: true,
                  fillColor: Colors.white.withOpacity(0.02),
                  filled: true,
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.green)
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminText.withOpacity(0.1)),
                      onPressed: _upload, 
                      child: Text("EXECUTE UPLOAD", style: TextStyle(color: AppColors.adminText))
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
