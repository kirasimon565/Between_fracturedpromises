import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/firestore_service.dart';

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
    if (_idController.text.isEmpty || _jsonController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // Validate JSON
      // In real app, we'd use jsonDecode check
      await _firestore.uploadEpisode(_idController.text, {
        'raw_data': _jsonController.text // Simplified for demo
      });
      Get.snackbar("Success", "Episode uploaded!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Episode")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: "Episode ID (e.g. episode_2)"),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _jsonController,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: "Paste JSON Here",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _upload, child: Text("UPLOAD TO FIRESTORE"))
          ],
        ),
      ),
    );
  }
}
