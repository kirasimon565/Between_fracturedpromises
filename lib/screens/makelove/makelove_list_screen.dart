import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../services/story_engine.dart';
import '../../theme/colors.dart';
import '../../theme/theme.dart';

class MakeloveListScreen extends StatefulWidget {
  @override
  _MakeloveListScreenState createState() => _MakeloveListScreenState();
}

class _MakeloveListScreenState extends State<MakeloveListScreen> {
  final ThemeService _themeService = Get.find<ThemeService>();
  final StoryEngine _engine = Get.find<StoryEngine>();

  @override
  void initState() {
    super.initState();
    _themeService.setSecretMode(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.makeloveBackground,
      appBar: AppBar(
        title: const Text("MAKELOVE", style: TextStyle(letterSpacing: 6, fontSize: 16, fontWeight: FontWeight.w300)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        final threads = _engine.activeThreads.where((t) => t.id.toLowerCase() == 'daniel').toList();

        return ListView.builder(
          itemCount: threads.length,
          itemBuilder: (context, index) {
            final thread = threads[index];
            final lastMsg = thread.messages.last;
            final name = thread.id.toUpperCase();

            return _buildMatchTile(name, lastMsg.content);
          },
        );
      }),
    );
  }

  Widget _buildMatchTile(String name, String lastMessage) {
    return GestureDetector(
      onTap: () => Get.toNamed('/makelove/chat', arguments: name),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 120,
        decoration: BoxDecoration(
          // Use the portrait as the background for the tile
          image: DecorationImage(
            image: AssetImage(AppConstants.getAvatarPath(name)),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.makelovePrimary.withOpacity(0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
              Text(
                lastMessage, 
                maxLines: 1, 
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontStyle: FontStyle.italic)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
